//
//  STAudioPlayer.m
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "STAudioPlayer.h"
#import "STAudioPackages.h"

#define DEFAULT_SAMPLE_RATE 8000
#define MAX_BUFFER_SIZE 0x50000                // audio queue 的每一个buffer的最大长度为 320k bytes

#define QUEUE_BUFFER_NUMBER  3                  // audio queue buffer个数

@interface STAudioPlayer () {
    AudioStreamBasicDescription   m_dataFormat;         // audio queue 的参数
    AudioQueueRef m_aq;                                 // audio queue
    
    AudioQueueBufferRef m_aqBuffer[QUEUE_BUFFER_NUMBER];   // audio buffers
   
    BOOL m_valideBuffer[QUEUE_BUFFER_NUMBER];
}

@property (nonatomic, readonly) BOOL isWantStop;
@property (nonatomic, strong) STAudioPackages* musicPackages;
@property (nonatomic, assign) BOOL isMusicLooping;

- (void)continuePlay;
- (void)clearMusic;

- (void)setPlaying:(BOOL)val;
- (UInt32)getBufferSize:(AudioQueueRef)audioQueue withStreamDescription:(AudioStreamBasicDescription)asbDescript withSecond:(float)seconds;


- (int)getValidateBufferIndex;
- (void)setValidateAllBuffer:(BOOL)val;
- (void)invalidateBuffer:(AudioQueueBufferRef)buffer withInvalidate:(BOOL)val;
@end

// audio queue 播放时的回调函数
static void audioQueueOutputCallback (void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    STAudioPlayer* player = (__bridge STAudioPlayer*)inUserData;
    
    [player invalidateBuffer:inBuffer withInvalidate:true];
    
    if (player.delegate) {
        if (player.musicPackages != NULL) {
            [player continuePlay];
        } else {
            if ([player.delegate respondsToSelector:@selector(onBufferPlayEnd:withMaxBufferSize:)]) {
                [player.delegate onBufferPlayEnd:player withMaxBufferSize:player.audioQueueBufferSize];
            }
        }
    }
}

// audio params 监听回调函数
static void audioQueueRunningProc( void *              inUserData,
                                  AudioQueueRef           inAQ,
                                  AudioQueuePropertyID    inID) {
    STAudioPlayer* player = (__bridge STAudioPlayer *)inUserData;
    UInt32 isActived;
    UInt32 size = sizeof(isActived);
    OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &isActived, &size);
    [player setPlaying:isActived];
    
    if (player.delegate) {
        if (isActived) {
            [player.delegate onPlayStart:player];
        } else {
            [player.delegate onPlayStop:player];
        }
    }
    
    if ((result == noErr) && (!isActived))
        [[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

@implementation STAudioPlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        _isReady = NO;
        _isPlaying = NO;
        _audioQueueBufferSize = 0;
        self.musicPackages = NULL;
        self.isMusicLooping = NO;
        _isWantStop = NO;
        _voiceVolume = 1.0;
    }
    return self;
}

- (instancetype)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds {
    if (self = [self init]) {
        [self setAudioConfigure:audioConfigure];
        [self setBufferMaxSeconds:seconds];
        [self setupAudioQueue];
    }
    return self;
}

- (void)setPlaying:(BOOL)val {
    _isPlaying = val;
}

- (void)setBufferMaxSeconds:(Float32)seconds {
    _bufferMaxSeconds = seconds;
}

- (BOOL)setupAudioQueue {
    if (_isPlaying) {
        NSLog(@"[Error]setupAudioQueue: audio queue is playing, please stop it before trying again. ");
        return false;
    }
    
    if (m_aq) {
        NSLog(@"[Error]setupAudioQueue: You should call releaseAudioQueue first before playing!");
        return NO;
    }
    
    OSStatus bRet = 0;
    memset(&m_valideBuffer, 0, sizeof(m_valideBuffer));
    
    do {
        bRet = AudioQueueNewOutput(&m_dataFormat, audioQueueOutputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &m_aq);
        if (bRet != noErr) {
            NSLog(@"[Error]setupAudioAueue: new output audio queue failed!");
            break;;
        }
        
        _audioQueueBufferSize = [self getBufferSize:m_aq withStreamDescription:m_dataFormat withSecond:self.bufferMaxSeconds];
        
        bRet = AudioQueueAddPropertyListener(m_aq, kAudioQueueProperty_IsRunning, audioQueueRunningProc, (__bridge void*)self);
        if (bRet != noErr) {
            NSLog(@"[Error]setupAudioAueue: add property listener(for play back end call back) failed!");
            break;
        }
        
        // 创建并初始化好buffer，但并不急着马上enqueue到audio queue中
        for (int i = 0; i < QUEUE_BUFFER_NUMBER; ++i) {
            bRet = AudioQueueAllocateBuffer(m_aq, (UInt32)self.audioQueueBufferSize, &m_aqBuffer[i]);
            if (bRet != noErr) {
                NSLog(@"[Error]setupAudioAueue: alloc audio queue buffer failed!");
                break;
            }
            m_valideBuffer[i] = YES;
        }
        
        bRet = AudioQueueSetParameter(m_aq, kAudioQueueParam_Volume, _voiceVolume);
        if (bRet != noErr) {
            NSLog(@"[Warnning]setupAudioAueue:: set audio volume property failed!");
        }
        
        _isReady = YES;
        
        return YES;
    } while(0);
    
    // 以下为出错时的处理方式
    [self releaseAudioQueue];
    return NO;
}

- (void)releaseAudioQueue {
    if (_isPlaying) {
        NSLog(@"[Error]releaseAudioQueue: audio queue is playing, please stop it before trying again. ");
        return;
    }
    
    if (m_aq) {
        for (int i = 0; i < QUEUE_BUFFER_NUMBER; i++) {
            if (m_valideBuffer[i]) {
                AudioQueueFreeBuffer(m_aq, m_aqBuffer[i]);
                m_aqBuffer[i] = NULL;
            }
            memset(&m_valideBuffer, 0, sizeof(m_valideBuffer));
        }
        
        AudioQueueDispose(m_aq, true);
        m_aq = NULL;
    }
    
    _isReady = NO;
}

- (int)getValidateBufferIndex {
    for (int i = 0; i < QUEUE_BUFFER_NUMBER; i++) {
        if (m_valideBuffer[i]) {
            return i;
        }
    }
    return -1;
}

- (void)setValidateAllBuffer:(BOOL)val {
    memset(&m_valideBuffer, val, sizeof(m_valideBuffer));
}

- (void)invalidateBuffer:(AudioQueueBufferRef)buffer withInvalidate:(BOOL)val {
    for (int i = 0; i < QUEUE_BUFFER_NUMBER; i++) {
        if (m_aqBuffer[i] == buffer) {
            m_valideBuffer[i] = val;
        }
    }
}

- (BOOL)writeQueue:(const void*)bytes withLength:(unsigned long)length {
    if (!_isReady) {
        NSLog(@"[Error]writeAudio: Did you forget to call setupAudioQueue before? ");
        return NO;
    }
    
    int index = [self getValidateBufferIndex];
    if (index == -1) {
        // newma todo: 处理一下当前没有可用的audio queue buffer的情况，目前是直接不忽略此段要播放的音频
        NSLog(@"[Error]writeAudio: No more queue buffer is validate, perhaps you should think about increasing QUEUE_BUFFER_NUMBER");
        return NO;
    }
    
    if (self.audioQueueBufferSize < length) {
        length = self.audioQueueBufferSize;
        NSLog(@"[Warning]writeAudio: Audio data length is out of size of %ld, outside part will be excluded!", (unsigned long)self.audioQueueBufferSize);
    }
    
    memcpy(m_aqBuffer[index]->mAudioData, bytes, length);
    m_aqBuffer[index]->mAudioDataByteSize = (UInt32)length;
    m_valideBuffer[index] = NO;
    AudioQueueEnqueueBuffer(m_aq, m_aqBuffer[index], 0, NULL);
    
    return YES;
}

- (BOOL)writeQueue:(NSData*)data {
    return [self writeQueue:data.bytes  withLength:[data length]];
}

- (BOOL)startMusic:(NSData *)music loop:(BOOL)isLooping {
    if (_isPlaying) {
        NSLog(@"[Error]writeAudio: Sorry, it is playing. You should stop it before!");
        return NO;
    }
    
    self.musicPackages = [[STAudioPackages alloc]initWithData:music packageSize:self.audioQueueBufferSize];
    self.isMusicLooping = isLooping;
    
    for (int i = 0; i < QUEUE_BUFFER_NUMBER; i++) {
        [self writeQueue:[self.musicPackages readNextPackage]];
    }
    
    return [self startQueue];
}

- (void)continuePlay {
    if (![self.musicPackages validate]) {  // play end

        if (!self.isMusicLooping) {
            [self stopQueue];    // stop when no looping play
        } else {
            [self.musicPackages rewind];
            NSLog(@"[Debug]continuePlay: Start to play loop.");
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayEnd:)]) {
            [self.delegate onPlayEnd:self];
        }
        
        if (!self.isMusicLooping) {
            return;
        }
    }
    
    NSData* data = [self.musicPackages readNextPackage];
    [self writeQueue:data];
}

- (void)clearMusic {
    self.musicPackages = NULL;
    self.isMusicLooping = NO;
    
    [self setValidateAllBuffer:YES];
}

- (void)setAudioConfigure:(STAudioConfigure)configure {
    _audioConfigure = configure;
    m_dataFormat.mChannelsPerFrame = configure.channal;
    m_dataFormat.mBytesPerFrame = m_dataFormat.mBytesPerPacket = configure.bit;
    
    
    m_dataFormat.mFormatID         = kAudioFormatLinearPCM;
    m_dataFormat.mSampleRate       = configure.sampleRate;
    m_dataFormat.mChannelsPerFrame = configure.channal;
    m_dataFormat.mBitsPerChannel   = configure.bit;
    m_dataFormat.mBytesPerPacket   = m_dataFormat.mBytesPerFrame =  m_dataFormat.mChannelsPerFrame * (configure.bit >> 3);
    m_dataFormat.mFramesPerPacket  = 1;
    m_dataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
}

- (UInt32)getBufferSize:(AudioQueueRef)audioQueue withStreamDescription:(AudioStreamBasicDescription)asbDescript withSecond:(float)seconds {
    int maxPacketSize = asbDescript.mBytesPerPacket;
    if (maxPacketSize == 0) {   // VBR(变长音频数据)
        NSLog(@"[Warnning]getBufferSize: Audio player don't support VBR audio frame");
        return MAX_BUFFER_SIZE;
    }
    
    UInt32 numBytesForTime = asbDescript.mSampleRate * maxPacketSize * seconds;
    return (numBytesForTime < MAX_BUFFER_SIZE) ? numBytesForTime : MAX_BUFFER_SIZE;
}

- (BOOL)startQueue {
    if (!_isReady) {
        NSLog(@"[Error]start: Did you forget to call setupAudioQueue before?");
        return NO;
    }
    
    if (_isPlaying) {
        NSLog(@"[Error]start: audio player is playing, please stop it before trying again!");
        return NO;
    }
    
    AudioQueueStart(m_aq, 0);
    
    return YES;
}

- (void)stopQueue {
    if (!_isReady) {
        NSLog(@"[Error]stop: Did you forget to call setupAudioQueue before?");
        return;
    }
    AudioQueueStop(m_aq,TRUE);
    
    // 停止时，playMusic信息清空
    [self clearMusic];
}

- (void)pauseQueue {
    if (_isPlaying && _isReady) {
        AudioQueuePause(m_aq);
    }
}

- (void)resumeQueue {
    if (_isReady && !_isPlaying) {
        AudioQueueStart(m_aq, 0);
    }
}

- (void)dealloc {
    [self releaseAudioQueue];
}

@end

