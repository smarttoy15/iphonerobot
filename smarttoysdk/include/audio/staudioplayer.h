//
//  STAuidoPlayer.h
//  smarttoysdk
//
//  Created by newma on 3/22/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-25 17:29
 Descript: Log日记函数
 */


#ifndef __STAUDIOPLAYER_H__
#define __STAUDIOPLAYER_H__

#import "staudioconfigure.h"

@class STAudioPlayer;

@protocol STAudioPlayCallback <NSObject>

- (void)onPlayStart:(STAudioPlayer*)player;
- (void)onPlayStop:(STAudioPlayer*)player;

@optional
- (void)onNoMoreDataToPlay:(STAudioPlayer*)player;

@end


@interface STAudioPlayer : NSObject

@property (nonatomic, readonly) STAudioConfigure audioConfigure;
@property (nonatomic, assign) id<STAudioPlayCallback> delegate;
@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) BOOL isInitialized;

- (STAudioPlayer*)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds;

- (BOOL)start;
- (void)stop;
- (void)pause;
- (void)resume;

- (BOOL)writeAudio:(const void*)bytes withLength:(unsigned long)length;
- (BOOL)writeAudio:(NSData*)data;

@end

#endif // __STAUDIOPLAYER_H__
