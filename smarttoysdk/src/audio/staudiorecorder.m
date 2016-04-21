//
//  staudiorecorder.m
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import "STAudioRecorder.h"

#define MAX_AQBUFFER_SIZE 0x50000

static const int MAX_AQBUFFER_COUNT = 3;

@interface STAudioRecorder ()
{
    AudioStreamBasicDescription m_audioStreamDesp;
    AudioQueueRef m_aq;
    AudioQueueBufferRef m_aqBuffer[MAX_AQBUFFER_COUNT];
    
    UInt32 m_maxBufferSize;
}
@property(nonatomic, assign) BOOL isWantStop;

- (AudioQueueRef)getAudioQueue;
- (AudioQueueBufferRef)getAudioBufferByIndex:(int)index;
- (void)setRecording:(BOOL)val;

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
    
    //NSLog(@"record data length %ld", inBuffer->mAudioDataByteSize);
    if (!aqRecorder.isWantStop) {
        if (aqRecorder && aqRecorder.delegate) {
            NSData* recordData = [[NSData alloc]initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
            [aqRecorder.delegate onRecordData:recordData withRecorder:aqRecorder];
        }
    } else {
        NSLog(@"[Debug]handleInputBuffer: Recorder is wantted to stopped so no to callback");
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
    
    if (result != noErr) {
        NSLog(@"[Error]audioQueueRuningProc: Get audio queue property of isRunning failed!");
        return;
    }
    
    if (isRunning == recorder.isRecording) {
        NSLog(@"[Warnning]audioQueueRuningProc: Did you call start/stop twice continuously?");
    }
    
    [recorder setRecording:isRunning];
    
    if (recorder.delegate) {
        if (isRunning) {
            [recorder.delegate onRecordStart:recorder];
        } else {
            [recorder.delegate onRecordStop:recorder];
        }
    }
}

@implementation STAudioRecorder

- (STAudioRecorder*)init {
    if (self = [super init]) {
        _isReady = NO;
        _isRecording = NO;
        
        [self setBufferMaxSeconds:0];
    }
    return self;
}

- (void)setAudioConfigure:(STAudioConfigure)audioConfigure {
    _audioConfigure = audioConfigure;
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

- (void)setBufferMaxSeconds:(Float32)seconds {
    _bufferMaxSeconds = seconds;
}

- (STAudioRecorder*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds {
    if (self = [self init]) {
        [self setAudioConfigure:audioConfigure];
        [self setBufferMaxSeconds:seconds];
        
        [self setupAudioQueue];
    }
    return self;
}

- (AudioQueueRef)getAudioQueue {
    return m_aq;
}

- (AudioQueueBufferRef)getAudioBufferByIndex:(int)index {
    return m_aqBuffer[index];
}

- (void)setRecording:(BOOL)val {
    _isRecording = val;
}

- (BOOL)setupAudioQueue {
    if (_isRecording) {
        NSLog(@"[Error]setupAudioQueue: audio recorder is recording, please stop it before trying again.");
        return false;
    }
    
    if (m_aq) {
        NSLog(@"[Error]setupAudioQueue: You should call releaseAudioQueue first before recording!");
        return NO;
    }
    
    OSStatus bRet = noErr;
    do {
        bRet = AudioQueueNewInput (&m_audioStreamDesp,
                                   handleInputBuffer,
                                   (__bridge void*)self,
                                   CFRunLoopGetCurrent(),
                                   kCFRunLoopCommonModes,
                                   0,
                                   &m_aq);
        if (bRet != noErr) {
            NSLog(@"[Error]setupAudioQueue: New input audio queue failed!");
            break;
        }
        
        m_maxBufferSize = [self getBufferSize:m_aq withDescript:m_audioStreamDesp withSeconds:self.bufferMaxSeconds];
        
        bRet = AudioQueueAddPropertyListener(m_aq, kAudioQueueProperty_IsRunning, audioQueueRunningProc, (__bridge void*)self);
        if (bRet != noErr) {
            NSLog(@"[Error]setupAudioQueue: Add property listener(for play back end call back) failed!");
            break;
        }
        
        for (int i = 0; i < MAX_AQBUFFER_COUNT; ++i) {
            bRet = AudioQueueAllocateBuffer(m_aq, m_maxBufferSize, &m_aqBuffer[i]);
            if (bRet != noErr) {
                NSLog(@"alloc audio queue buffer[%d] failed!", i);
                // Not need to do anything, just give an alert!
            }
        }
        
        _isReady = YES;
        return YES;
    } while(0);
    
    // if any error
    [self releaseAudioQueue];
    return NO;
}

- (void)releaseAudioQueue {
    if (_isRecording) {
        AudioQueueStop(m_aq, YES);
        //NSLog(@"[Error]releaseAudioQueue: audio recorder is recording, please stop it before trying again.");
        //return;
    }
    
    if (m_aq) {
        for (int i = 0; i < MAX_AQBUFFER_COUNT; i++) {
            AudioQueueFreeBuffer(m_aq, m_aqBuffer[i]);
        }
        AudioQueueDispose(m_aq, true);
        m_aq = NULL;
    }
    _isReady = NO;
}

- (UInt32)getBufferSize:(AudioQueueRef)inAQ withDescript:(AudioStreamBasicDescription)desp withSeconds:(Float32)seconds {
    int maxPacketSize = desp.mBytesPerPacket;
    if (maxPacketSize == 0) {
        NSLog(@"[Warnning]getBufferSize: Audio recorder don't support VBR audio frame");
        return MAX_AQBUFFER_SIZE;
    }
    
    Float64 numBytesForTime = desp.mSampleRate * maxPacketSize * seconds;
    return (UInt32)(numBytesForTime < MAX_AQBUFFER_SIZE ? numBytesForTime : MAX_AQBUFFER_SIZE);
}

- (BOOL)start {
    if (!_isReady) {
        NSLog(@"[Error]start: Did you forget to call setupAudioQueue before? ");
        return NO;
    }
    
    if (_isRecording) {
        NSLog(@"[Error]start: The aduio queue is recording now, you have to stop it first!");
        return NO;
    }
    
    OSStatus status = noErr;
    for (int i = 0; i < MAX_AQBUFFER_COUNT; ++i) {
        status = AudioQueueEnqueueBuffer(m_aq, m_aqBuffer[i], 0, NULL);
        if (status != noErr) {
            NSLog(@"enqueue audio queue buffer[%d] failed!", i);
            // Not need to do anything, just give an alert!
        }
    }

    self.isWantStop = NO;
    status = AudioQueueStart(m_aq, NULL);
    if (status != noErr) {
        NSLog(@"[Error]start: AudioQueueStart called failed! Error code: %ld", status);
        return NO;
    }
    
    return YES;
}

- (void)stop {
    if (!_isReady) {
        NSLog(@"[Error]stop: Did you forget to call setupAudioQueue before? ");
        return;
    }
    self.isWantStop = YES;
    AudioQueueStop(m_aq, YES);
}

- (void)dealloc {
    [self releaseAudioQueue];
}

@end