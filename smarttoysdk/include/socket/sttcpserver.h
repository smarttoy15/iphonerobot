//
//  TCPServer.h
//  test_proj
//
//  Created by newma on 2/9/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: TCP服务端类STTCPServer以及其回调的STTCPServerHandler
 */

#ifndef STTCPSERVER_H
#define STTCPSERVER_H

#import "sttcprecieve_i.h"
#import "sttcpsocket.h"

@class STTCPServer;

@protocol STTCPServerHandler <NSObject>
@optional

/**********************************************************
 @descript：server启动进入监听后的回调
 @argument：(STTCPServer*) server：当前所处理的tcp server实例
 **********************************************************/
- (void) onServerStart:(STTCPServer*) server;

/**********************************************************
 @descript：当有连接进入时的回调
 @argument：(STTCPServer*) server：当前所处理的tcp server实例
  @argument：(STTCPSocket*)socket：成功建立连接的socket
 **********************************************************/
- (void) onAccept:(STTCPServer*)server withSocket:(STTCPSocket*)socket;

/**********************************************************
 @descript：当有连接断开时的回调
 @argument：(STTCPServer*) server：当前所处理的tcp server实例
 @argument：(STTCPSocket*)socket：当前断开连接的socket
 **********************************************************/
- (void) onSocketClose:(STTCPServer*)server withSocket:(STTCPSocket*)socket;


/**********************************************************
 @descript：server关闭后的回调
 @argument：(STTCPServer*) server：当前所处理的tcp server实例
 **********************************************************/
- (void) onServerClose:(STTCPServer*) server;
@end

@interface STTCPServer : NSObject

@property (nonatomic, readwrite) int port;                      // 监听端口
@property (nonatomic, assign) id<STTCPServerHandler> delegate;
@property (nonatomic, assign) id<STTCPRecieverInterface> readDelegate;
@property (nonatomic, readonly) BOOL isWorking;

- (STTCPServer*)initWithPort:(int)port;

- (BOOL)start;

- (void)close;

// Socket连接的管理，session
- (STTCPSocket*)getSessionById:(int)sessionId;
- (long)getSessionCount;
- (void)removeSessionById:(int)sessionId;
- (void)removeAllSessions;

- (void)sendAllSessionsMessage:(NSData*)message;

@end

#endif // STTCPSERVER_H
