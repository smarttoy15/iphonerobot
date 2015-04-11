//
//  STAudioPlayer.m
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "audio/staudioplayer.h"
#import "misc/stlog.h"

#define DEFAULT_SAMPLE_RATE 8000
#define MAX_BUFFER_SIZE 0x50000                // audio queue 的每一个buffer的最大长度为 320k bytes

static const int g_cNumberBuffers = 3; //audio queue buffer个数

@interface STAudioPlayer () {
    AudioStreamBasicDescription   m_dataFormat;         // audio queue 的参数
    AudioQueueRef m_aq;                                 // audio queue
    
    AudioQueueBufferRef m_aqBuffer[g_cNumberBuffers];   // audio buffers
    int32_t                        m_bufferByteSize;      // 每个audio buffer的长度
    
    BOOL m_valideBuffer[g_cNumberBuffers];
    
    Float32 m_maxBufferSeconds;                            // 每个audio queue buffer最大能存放的音频时间（秒数），最终audio queue buffer的长度是不会超过MAX_BUFFER_SIZE的
}

- (void)setIsRunning:(BOOL)val;

- (void)setupAudioFormat:(STAudioConfigure)audioConfigure;
- (int32_t)getBufferSize:(AudioQueueRef)audioQueue withStreamDescription:(AudioStreamBasicDescription)asbDescript withSecond:(float)seconds;
- (BOOL)setupAudioQueue;
- (void)releaseAudioQueue;

- (int)getValidateBufferIndex;
- (BOOL)checkAllBuffersValidate;
- (void)invalidateBuffer:(AudioQueueBufferRef)buffer withInvalidate:(BOOL)val;
@end

// audio queue 播放时的回调函数
static void audioQueueOutputCallback (void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    STAudioPlayer* player = (__bridge STAudioPlayer*)inUserData;
    
    [player invalidateBuffer:inBuffer withInvalidate:true];
    
    if (player.delegate && [player checkAllBuffersValidate]) {
        [player.delegate onNoMoreDataToPlay:player];
    }
}

// audio params 监听回调函数
static void audioQueueRunningProc( void *              inUserData,
                                  AudioQueueRef           inAQ,
                                  AudioQueuePropertyID    inID) {
    STAudioPlayer* player = (__bridge STAudioPlayer *)inUserData;
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
    [player setIsRunning:isRunning];
    
    if (player.delegate) {
        if (isRunning) {
            [player.delegate onPlayStart:player];
        } else {
            [player.delegate onPlayStop:player];
        }
    }
    
    if ((result == noErr) && (!isRunning))
        [[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

@implementation STAudioPlayer

@synthesize audioConfigure = _audioConfigure;
@synthesize delegate = _delegate;
@synthesize isRunning = _isRunning;
@synthesize isInitialized = _isInitialized;

- (STAudioPlayer*)init {
    self = [super init];
    if (self) {
        STAudioConfigure configure = { emMono, DEFAULT_SAMPLE_RATE, em8Bit};
        [self setupAudioFormat:configure];
        _isInitialized = NO;
        _isRunning = NO;
    }
    return self;
}

- (STAudioPlayer*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds {
    if (self = [self init]) {
        [self setupAudioFormat:audioConfigure];
        m_maxBufferSeconds = seconds;
    }
    return self;
}

- (void)setIsRunning:(BOOL)val {
    _isRunning = val;
}

- (BOOL)setupAudioQueue {
    OSStatus bRet = 0;
    memset(&m_valideBuffer, 0, sizeof(m_valideBuffer));
    
    do {
        bRet = AudioQueueNewOutput(&m_dataFormat, audioQueueOutputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &m_aq);
        if (bRet) {
            STLog(@"error: new output audio queue failed!");
            break;;
        }
    
        m_bufferByteSize = [self getBufferSize:m_aq withStreamDescription:m_dataFormat withSecond:m_maxBufferSeconds];

        bRet = AudioQueueAddPropertyListener(m_aq, kAudioQueueProperty_IsRunning, audioQueueRunningProc, (__bridge void*)self);
        if (bRet) {
            STLog(@"error: add property listener(for play back end call back) failed!");
        }

        // 创建并初始化好buffer，但并不急着马上enqueue到audio queue中
        for (int i = 0; i < g_cNumberBuffers; ++i) {
            bRet = AudioQueueAllocateBuffer(m_aq, m_bufferByteSize, &m_aqBuffer[i]);
            if (bRet) {
                STLog(@"error: alloc audio queue buffer failed!");
                break;
            }
            m_valideBuffer[i] = YES;
        }
        if (bRet) {
            break;
        }
    
        bRet = AudioQueueSetParameter(m_aq, kAudioQueueParam_Volume, 1.0);
        if (bRet) {
            STLog(@"error: set audio volume property failed!");
        }
        
        _isInitialized = YES;
        
        return YES;
    } while(0);
    
    // 以下为出错时的处理方式
    [self releaseAudioQueue];
    return NO;
}

- (void)releaseAudioQueue {
    for (int i = 0; i < g_cNumberBuffers; i++) {
        if (m_valideBuffer[i]) {
            AudioQueueFreeBuffer(m_aq, m_aqBuffer[i]);
            m_aqBuffer[i] = NULL;
        }
        memset(&m_valideBuffer, 0, sizeof(m_valideBuffer));
    }
    
    if (m_aq) {
        AudioQueueDispose(m_aq, true);
        m_aq = NULL;
    }
    
    _isInitialized = NO;
}

- (int)getValidateBufferIndex {
    for (int i = 0; i < g_cNumberBuffers; i++) {
        if (m_valideBuffer[i]) {
            return i;
        }
    }
    return -1;
}

- (BOOL)checkAllBuffersValidate {
    for (int i = 0; i < g_cNumberBuffers; i++) {
        if (!m_valideBuffer[i]) {
            return NO;
        }
    }
    return YES;
}

- (void)invalidateBuffer:(AudioQueueBufferRef)buffer withInvalidate:(BOOL)val {
    for (int i = 0; i < g_cNumberBuffers; i++) {
        if (m_aqBuffer[i] == buffer) {
            m_valideBuffer[i] = val;
        }
    }
}

- (BOOL)writeAudio:(const void*)bytes withLength:(unsigned long)length {
    if (!_isInitialized) {
        STLog(@"error: audio queue hasn't been initialized!");
        return NO;
    }
    
    int index = [self getValidateBufferIndex];
    if (index == -1) {
        // newma todo: 处理一下当前没有可用的audio queue buffer的情况，目前是直接不忽略此段要播放的音频
        return NO;
    }
    
    memcpy(m_aqBuffer[index]->mAudioData, bytes, length);
    m_aqBuffer[index]->mAudioDataByteSize = (UInt32)length;
    AudioQueueEnqueueBuffer(m_aq, m_aqBuffer[index], 0, NULL);
    
    m_valideBuffer[index] = NO;
    
    return YES;
}

- (BOOL)writeAudio:(NSData*)data {
    return [self writeAudio:data.bytes  withLength:[data length]];
}

- (void)setupAudioFormat:(STAudioConfigure)audioConfigure {
    m_dataFormat.mChannelsPerFrame = audioConfigure.channal;
    m_dataFormat.mBytesPerFrame = m_dataFormat.mBytesPerPacket = audioConfigure.bit;
    
    
    m_dataFormat.mFormatID         = kAudioFormatLinearPCM;
    m_dataFormat.mSampleRate       = audioConfigure.sampleRate;
    m_dataFormat.mChannelsPerFrame = audioConfigure.channal;
    m_dataFormat.mBitsPerChannel   = audioConfigure.bit;
    m_dataFormat.mBytesPerPacket   = m_dataFormat.mBytesPerFrame =  m_dataFormat.mChannelsPerFrame * (audioConfigure.bit >> 3);
    m_dataFormat.mFramesPerPacket  = 1;
    m_dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
}

- (int32_t)getBufferSize:(AudioQueueRef)audioQueue withStreamDescription:(AudioStreamBasicDescription)asbDescript withSecond:(float)seconds {
    int maxPacketSize = asbDescript.mBytesPerPacket;
    if (maxPacketSize == 0) {   // VBR(变长音频数据)
        STLog(@"error: don't support VBR");
        return MAX_BUFFER_SIZE;
    }
    
    int32_t numBytesForTime = asbDescript.mSampleRate * maxPacketSize * seconds;
    return (numBytesForTime < MAX_BUFFER_SIZE) ? numBytesForTime : MAX_BUFFER_SIZE;
}

- (BOOL)start {
    if (_isRunning) {
        STLog(@"audio player has been running");
        return NO;
    }
    
    if (!_isInitialized && ![self setupAudioQueue]){
        STLog(@"setupAudioQueue failed!");
        return NO;
    }
    
    AudioQueueReset(m_aq);
    AudioQueueStart(m_aq, 0);
    
    return YES;
}

- (void)stop {
    AudioQueueStop(m_aq,TRUE);
}

- (void)pause {
    if (_isRunning && _isInitialized) {
        AudioQueuePause(m_aq);
    }
}

- (void)resume {
    if (_isInitialized && !_isRunning) {
        AudioQueueStart(m_aq, 0);
    }
}

- (void)dealloc {
    [self releaseAudioQueue];
}

@end