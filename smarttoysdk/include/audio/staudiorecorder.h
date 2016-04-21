//
//  STAudioRecord.h
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#ifndef __STAUDIORECORDER_H__
#define __STAUDIORECORDER_H__

#include <AudioToolbox/AudioToolbox.h>
#include <Foundation/Foundation.h>
#include "STAudioConfigure.h"

@class STAudioRecorder;

@protocol STAudioRecorderCallback <NSObject>

/**
 *  Record callback.
 *
 *  @param data     Recorded data
 *  @param recorder The instance which recording data.
 */
- (void)onRecordData:(NSData*)data withRecorder:(STAudioRecorder*)recorder;

@optional

// event callback
- (void)onRecordStart:(STAudioRecorder*)recorder;
- (void)onRecordStop:(STAudioRecorder*)recorder;

@end

@interface STAudioRecorder : NSObject

@property(nonatomic, assign) id<STAudioRecorderCallback> delegate;

@property(nonatomic, readonly) BOOL isRecording;     // It should be true when you called start and false when you called stop
@property(nonatomic, readonly) BOOL isReady;         // It would be true only when call setupAudioQueue sucessfully

@property(nonatomic, readonly) STAudioConfigure audioConfigure;
@property(nonatomic, readonly) Float32 bufferMaxSeconds;

/**
 *  call this function exactly like call init-setAudioConfigure-setBufferMaxSeconds-setupAudioQueue in sequeue.
 *
 *  @param audioConfigure
 *  @param seconds
 *
 *  @return
 */
- (STAudioRecorder*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds;

// Audio Configure
/**
 *  It won't be effective until you call the setupAudioQueue successfully.
 */
- (void)setAudioConfigure:(STAudioConfigure)audioConfigure;
- (void)setBufferMaxSeconds:(Float32)seconds;

// AudioQueue manage
/**
 *  setup audio queue and make the audio configure effective
 *
 *  @return True only if successfully
 */
- (BOOL)setupAudioQueue;
/**
 *  Call it to release the audio source whenever you won't need the Audio Queue anymore!
 */
- (void)releaseAudioQueue;

/**
 *  Start to record audio. If it was recording, calling this function will be failed. You have to stop it before.
 *
 *  @return
 */
- (BOOL)start;
/**
 *  Stop record.
 */
- (void)stop;

@end

#endif // __STAUDIORECORDER_H__