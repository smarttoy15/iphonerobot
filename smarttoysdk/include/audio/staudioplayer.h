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

#include <Foundation/Foundation.h>
#import "STAudioConfigure.h"

@class STAudioPlayer;

@protocol STAudioPlayCallback <NSObject>

@optional
/**
 *  Callback when the Audio Queue need more data. The data length that should write into argument[player] is no more than argument[size]
 *
 *  @param player
 *  @param size   Only the data in length of the size will be accept to play. Others out of the size will be eliminated!
 */
- (void)onBufferPlayEnd:(STAudioPlayer*)player withMaxBufferSize:(NSUInteger)size;

/**
 *  Called when startMusic play end. if no looping, then it will called after audio queue being called stop.
 *
 *  @param player 
 */
- (void)onPlayEnd:(STAudioPlayer*)player;

/**
 *  Start play callback
 */
- (void)onPlayStart:(STAudioPlayer*)player;
/**
 *  Stop play callback
 */
- (void)onPlayStop:(STAudioPlayer*)player;

@end

/**
 *  Low level Audio Player that just wrap an Audio Queue for play
 */
@interface STAudioPlayer : NSObject

@property (nonatomic, assign) id<STAudioPlayCallback> delegate;

@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isReady;


@property (nonatomic, readonly) Float32 bufferMaxSeconds;  // 每个audio queue buffer最大能存放的音频时间（秒数），最终audio queue buffer的长度是不会超过
@property (nonatomic, readonly) STAudioConfigure audioConfigure;
@property (nonatomic, readonly) NSUInteger audioQueueBufferSize;
@property (nonatomic, assign) Float32   voiceVolume;

/**
 *  This audio configure won't be effective until you call setupAudioQueue
 *
 *  @param configure Audio configure.
 */
- (void)setAudioConfigure:(STAudioConfigure)configure;
/**
 *  This will effect the audioQueueBufferSize.
 *
 *  @param seconds
 */
- (void)setBufferMaxSeconds:(Float32)seconds;

- (instancetype)initWithAudioConfigure:(STAudioConfigure)audioConfigure withBufferMaxSeconds:(Float32)seconds;

/**
 *  You should setupAudioQueue before starting to play.
 *
 *  @return True if successfully
 */
- (BOOL)setupAudioQueue;
/**
 *  Should releaseAudioQueue whenever you won't need it anymore!
 */
- (void)releaseAudioQueue;

- (BOOL)startQueue;
- (void)stopQueue;
- (void)pauseQueue;
- (void)resumeQueue;

/**
 *  Write data into audio queue for playing. Only those data inside audioQueueBufferSize will be accpeted by player to play. Other outside the range will be ignore! To make this work, you were supposed to have called startQueue before or after.
 *
 *  @param bytes  Data bytes array
 *  @param length Data acture size
 *
 *  @return True if successfully
 */
- (BOOL)writeQueue:(const void*)bytes withLength:(unsigned long)length;
- (BOOL)writeQueue:(NSData*)data;

/**
 *  Play an audio stream. It will auto start the audio queue and enqueue the audio data. When reaching the stream end, onPlayEnd will be callbacked. If no looping, stoping audio queue, otherwise play the audio stream allover again.
 *
 *  @param music     audio stream data
 *  @param isLooping loop play
 *
 *  @return True if successfully
 */
- (BOOL)startMusic:(NSData*)music loop:(BOOL)isLooping;

@end

#endif // __STAUDIOPLAYER_H__