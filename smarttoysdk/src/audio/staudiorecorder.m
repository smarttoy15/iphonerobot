//
//  staudiorecorder.m
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "misc/stlog.h"
#import "audio/staudiorecorder.h"

#define MAX_AQBUFFER_SIZE 0x50000

static const int MAX_AQBUFFER_COUNT = 3;

@interface STAudioRecorder ()
{
    AudioStreamBasicDescription m_audioStreamDesp;
    AudioQueueRef m_aq;
    AudioQueueBufferRef m_aqBuffer[MAX_AQBUFFER_COUNT];
    
    Float32 m_maxBufferSeconds;
    UInt32 m_maxBufferSize;
}

- (AudioQueueRef)getAudioQueue;
- (AudioQueueBufferRef)getAudioBufferByIndex:(int)index;
- (void)setIsRunning:(BOOL)isRunning;

- (void)setupAudioFormat:(STAudioConfigure)audioConfigure;
- (BOOL)setupAudioQueue;
- (void)releaseAudioQueue;

- (UInt32)getBufferSize:(AudioQueueRef)inAQ withDescript:(AudioStreamBasicDescription)desp withSeconds:(Float32)seconds;
@end

static void handleInputBuffer (
                               void                                 *aqData,
                               AudioQueueRef                        inAQ,
                               AudioQueueBufferRef                  inBuffer,
                               const AudioTimeStamp                 *inStartTime,
                               UInt32                               inNumPackets,       // 0 for CBR, otherwise for VBR
                               const AudioStreamPacketDescription   *inPacketDesc
                               ) {
    STAudioRecorder* aqRecorder = (__bridge STAudioRecorder*)aqData;
    
    if (aqRecorder && aqRecorder.delegate) {
        NSData* recordData = [[NSData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        [aqRecorder.delegate onRecordData:recordData withRecorder:aqRecorder];
    }
    
    AudioQueueEnqueueBuffer([aqRecorder getAudioQueue],
                             inBuffer,
                             0,
                             NULL
                             );
}

// audio params 监听回调函数
static void audioQueueRunningProc( void *              inUserData,
                                  AudioQueueRef           inAQ,
                                  AudioQueuePropertyID    inID) {
    STAudioRecorder* recorder = (__bridge STAudioRecorder *)inUserData;
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &isRunning, &size);
   
    if (result == noErr) {
        STLog(@"Get audio queue property of isRunning failed!");
        return;
    }
    
    [recorder setIsRunning:isRunning];
    
    if (recorder.delegate) {
        if (isRunning) {
            [recorder.delegate onRecordStart:recorder];
        } else {
            [recorder.delegate onRecordStop:recorder];
        }
    }
}

@implementation STAudioRecorder

@synthesize delegate = _delegate;
@synthesize isInitialized = _isInitialized;
@synthesize isRunning = _isRunning;

- (STAudioRecorder*)init {
    if (self = [super init]) {
        _isInitialized = NO;
        _isRunning = NO;
    }
    return self;
}
- (STAudioRecorder*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds {
    if (self = [self init]) {
        [self setupAudioFormat:audioConfigure];
        m_maxBufferSeconds = seconds;
    }
    return self;
}

- (AudioQueueRef)getAudioQueue {
    return m_aq;
}

- (AudioQueueBufferRef)getAudioBufferByIndex:(int)index {
    return m_aqBuffer[index];
}

- (void)setIsRunning:(BOOL)isRunning {
    _isRunning = isRunning;
}

- (void)setupAudioFormat:(STAudioConfigure)audioConfigure {
    m_audioStreamDesp.mChannelsPerFrame = audioConfigure.channal;
    m_audioStreamDesp.mBytesPerFrame = m_audioStreamDesp.mBytesPerPacket = audioConfigure.bit;
    
    
    m_audioStreamDesp.mFormatID         = kAudioFormatLinearPCM;
    m_audioStreamDesp.mSampleRate       = audioConfigure.sampleRate;
    m_audioStreamDesp.mChannelsPerFrame = audioConfigure.channal;
    m_audioStreamDesp.mBitsPerChannel   = audioConfigure.bit;
    m_audioStreamDesp.mBytesPerPacket   = m_audioStreamDesp.mBytesPerFrame =  m_audioStreamDesp.mChannelsPerFrame * (audioConfigure.bit >> 3);
    m_audioStreamDesp.mFramesPerPacket  = 1;
    m_audioStreamDesp.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
}

- (BOOL)setupAudioQueue {
    if (m_aq) {
        return YES;
    }
    
    OSStatus bRet = 0;
    do {
        bRet = AudioQueueNewInput (&m_audioStreamDesp,
                        handleInputBuffer,
                        (__bridge void*)self,
                        CFRunLoopGetCurrent(),
                        kCFRunLoopCommonModes,
                        0,
                        &m_aq);
        if (bRet) {
            STLog(@"new input audio queue failed!");
            break;
        }
        
        m_maxBufferSize = [self getBufferSize:m_aq withDescript:m_audioStreamDesp withSeconds:m_maxBufferSeconds];
        
        bRet = AudioQueueAddPropertyListener(m_aq, kAudioQueueProperty_IsRunning, audioQueueRunningProc, (__bridge void*)self);
        if (bRet) {
            STLog(@"error: add property listener(for play back end call back) failed!");
        }
        
        for (int i = 0; i < MAX_AQBUFFER_COUNT; ++i) {
            bRet = AudioQueueAllocateBuffer(m_aq, m_maxBufferSize, &m_aqBuffer[i]);
            if (bRet) {
                STLog(@"alloc audio queue buffer[%d] failed!", i);
                break;
            }
            
            bRet = AudioQueueEnqueueBuffer(m_aq, m_aqBuffer[i], 0, NULL);
            if (bRet) {
                STLog(@"enqueue audio queue buffer[%d] failed!", i);
                AudioQueueFreeBuffer(m_aq, m_aqBuffer[i]);
                break;
            }
        }
        if (bRet) {     // alloc buffer failed
            break;
        }
    
        _isInitialized = YES;
        return YES;
    } while(0);
    
    [self releaseAudioQueue];
    return NO;
}

- (void)releaseAudioQueue {
    if (m_aq) {
        AudioQueueDispose(m_aq, true);
        m_aq = NULL;
    }
    _isInitialized = NO;
}

- (UInt32)getBufferSize:(AudioQueueRef)inAQ withDescript:(AudioStreamBasicDescription)desp withSeconds:(Float32)seconds {
    int maxPacketSize = desp.mBytesPerPacket;
    if (maxPacketSize == 0) {
        STLog(@"Don't support VBR audio frame");
        return MAX_AQBUFFER_SIZE;
    }
    
    Float64 numBytesForTime = desp.mSampleRate * maxPacketSize * seconds;
    return (UInt32)(numBytesForTime < MAX_AQBUFFER_SIZE ? numBytesForTime : MAX_AQBUFFER_SIZE);
}

- (BOOL)start {
    if (!_isInitialized && ![self setupAudioQueue]) {
        return NO;
    }
    
    AudioQueueReset(m_aq);
    if (!AudioQueueStart(m_aq, 0)) {
        STLog(@"start audio queue failed!");
        return NO;
    }
    
    return YES;
}

- (void)stop {
    AudioQueueStop(m_aq, YES);
}

- (void)dealloc {
    [self releaseAudioQueue];
}

@end