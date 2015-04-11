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
#include "audio/staudioconfigure.h"

@class STAudioRecorder;

@protocol STAudioRecorderCallback <NSObject>

- (void)onRecordData:(NSData*)data withRecorder:(STAudioRecorder*)recorder;

@optional

- (void)onRecordStart:(STAudioRecorder*)recorder;
- (void)onRecordStop:(STAudioRecorder*)recorder;

@end

@interface STAudioRecorder : NSObject

@property(nonatomic, assign) id<STAudioRecorderCallback> delegate;
@property(nonatomic, readonly) BOOL isRunning;
@property(nonatomic, readonly) BOOL isInitialized;

- (STAudioRecorder*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds;

- (BOOL)start;
- (void)stop;

@end

#endif // __STAUDIORECORDER_H__
