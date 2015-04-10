
//
//  UDPReciever.h
//  test_proj
//
//  Created by newma on 2/28/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: STUDPReciever
 */

#ifndef STUDPRECIEVER_H
#define STUDPRECIEVER_H

#import "socket/studprecieve_i.h"

@interface STUDPSocket : NSObject

@property(nonatomic, readwrite)int localPort;        // 本地端口
@property(nonatomic, readwrite)NSString* remoteIp;   // 远程IP
@property(nonatomic, readwrite)int remotePort;       // 远程端口

@property(nonatomic, readonly)BOOL isValidate;       // 是否可以发送数据
@property(nonatomic, assign)id delegate;

/**********************************************************
 @descript：绑定端远程ip地址以及端口，这样就不必每次都要重新指定ip和端口了
 @argument：(NSString*)remoteIp：远程IPv4地址
 @argument：(int)port：远程端口
 **********************************************************/
- (BOOL)open;
- (BOOL)openWithRemoteIp:(NSString*)remoteIp withRemotePort:(int)port;

- (BOOL)send:(NSData*)data toIp:(NSString*)ip toPort:(int)port;
- (BOOL)send:(NSData*)data;
- (BOOL)send:(void*)data withLength:(long)length;

- (void)close;

@end

#endif //STUDPRECIEVER_H
