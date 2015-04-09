//
//  TCPSocket.h
//  test_proj
//
//  Created by newma on 2/9/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: STTCPSocket以及状态回调STTCPSocketHandler，STTCPSocket代表一系socket连接，既可是在client端也可以是在server端
 */

#ifndef STTCPSOCKET_H
#define STTCPSOCKET_H

#import <Foundation/Foundation.h>
#import "sttcprecieve_i.h"

@class STTCPSocket;

@protocol STTCPSocketHandler <NSObject>
@optional
/**********************************************************
 @descript：Socket连接成功时的回调，只有使用connect来创建连接时才会调用到此函数
 @argument：(STTCPSocket*)TCPSocket：当前的连接socket
 **********************************************************/
- (void)onConnected:(STTCPSocket*)TCPSocket;

/**********************************************************
 @descript：Socket断开时的回调
 @argument：(STTCPSocket*)TCPSocket：当前的连接socket
 **********************************************************/
- (void)onDisconnected:(STTCPSocket*)TCPSocket;
@end

@interface STTCPSocket: NSObject

@property (nonatomic, strong, readwrite) NSString* remoteIp;
@property (nonatomic, readwrite) int remotPort;
@property (nonatomic, assign) id<STTCPSocketHandler> delegate;
@property (nonatomic, assign) id<STTCPRecieverInterface> readDelegate;
@property (nonatomic, readonly) NSInputStream* input;
@property (nonatomic, readonly) NSOutputStream* output;
@property (nonatomic, readonly) int socketId;

// client自动连接创建socket
- (STTCPSocket*)initWithRemoteAddress:(NSString*)ip withPort:(int)port;
- (BOOL)connect:(NSString*)ip withPort:(int)port;
- (BOOL)connect;

// 封装现在有的socket
- (STTCPSocket*)initWithSocket:(int)cfNativeSocketHandler withId:(int)socketId;

// 发送数据
- (BOOL)send:(NSData*)data;
- (BOOL)send:(const void*)data dataLength:(unsigned long)length;

- (void)close;

- (BOOL)isValid;

@end

#endif //STTCPSOCKET_H
