//
//  STPeer.h
//  smarttoysdk
//
//  Created by newma on 3/17/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-17 15:07
 Descript: 设备发现的结点类，它既可以发出设备搜索信息，也可以处理接收到其它设备所发出来的搜索信息
            note：设备发现内部维护着一个其它设备信息的缓存表，可以通过IP来搜索对应的结点信息，当peer teardown时，此缓存表将会被清空
 */

#ifndef __STPEER_H__
#define __STPEER_H__

/*
 发送消息的协议头部
 */
typedef enum  {
    emNone,
    emSearch,   // 搜索
    emAdd,      // 增加设备
    emRemove    // 移除设备
} STPEERHEADTYPE;

@class STPeer;

@protocol STPeerEventHandler <NSObject>

@optional
/**********************************************************
 @descript：此函数是在本站点发出搜索信息后，接收到被搜索站点发过来的回包
 @argument：(STPeer*)local：本地peer的信息
 @argument：(NSString*)remoteIp：被搜索站点的IP地址，此时该站点的信息已保存在local中，可以通过该IP索引取出
 **********************************************************/
- (void)onRemotePeerAdd:(STPeer*)local withRemotePeerIp:(NSString*)remoteIp;
/**********************************************************
 @descript：此函数是在本站点发出搜索信息后，接收到被搜索站点关闭时发过来的回包
 @argument：(STPeer*)local：本地peer的信息
 @argument：(NSString*)remoteIp：被搜索站点的IP地址，此时该站点的信息已保存在local中，可以通过该IP索引取出
 **********************************************************/
- (void)onRemotePeerRemove:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp;

@optional
/**********************************************************
 @descript：在网络上有其它站点搜索到本peer，并且在本peer回复后，触发此函数回调
 @argument：(STPeer*)local：本地peer的信息
 @argument：(NSString*)remoteIp：被搜索站点的IP地址，此时该站点的信息已保存在local中，可以通过该IP索引取出
 **********************************************************/
- (void)onRemotePeerSearch:(STPeer*)local withRemotePeerIp:(NSString*)remoteIp;

@end

// 内部使用的protocol，用于抽象继承，主要用于抽象内部数据的处理
@protocol __STInternalAbstractPeer
@required
- (NSData*)getPeerInnerData;
- (void)setPeerInnerData:(NSData*)data;
- (STPeer*)createPeerByData:(NSData*)data withLocalIp:(NSString*)ip withLocalPort:(int)port;
@end

@interface STPeer : NSObject<__STInternalAbstractPeer>

@property (nonatomic, strong) NSString* localIp;    // 本地IP
@property (nonatomic, readwrite) int servicePort;     // 本地服务端口  change this port you have to teardown this service first! Or, it wouldn't effect.
@property (nonatomic, assign) id delegate;  //STPeerEventHandler

- (BOOL)setup;
- (void)searchPeer;
- (void)tearDown;

- (STPeer*)getPeerFromIp:(NSString*)ip;

@end


#endif
