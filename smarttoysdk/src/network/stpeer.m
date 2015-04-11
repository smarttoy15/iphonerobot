//
//  STPeer.m
//  smarttoysdk
//
//  Created by newma on 3/17/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-17 15:07
 Descript: Peer内部维护着的NSDictionary的信息列表。它不分是否是搜索到的设备还是别人搜索自已的，都会在此缓存中保留信息
 */

#import <Foundation/Foundation.h>

#import "network/stpeer.h"
#import "socket/studprecieve_i.h"
#import "socket/studpsocket.h"

#import "misc/stlog.h"

#define DEFAULT_PORT 8002

#define DEFAULT_BROADCAST_IP (@"255.255.255.255")

@interface STPeer() <STUDPSocketHandler>
{
    STUDPSocket* m_udp;
    
    NSDictionary* m_dictPeerInfo;   // 存放ip对应的peer类
}

- (void)addSearchPeer:(STPeer*)peer;
- (void)removeSearchPeer:(STPeer*)peer;
- (void)addResponsePeer:(STPeer*)peer;
- (void)removeResponsePeer:(STPeer*)peer;

- (void)sendMessageTo:(NSString*)remoteIp withMessageHead:(STPEERHEADTYPE)head;
@end


@implementation STPeer

@synthesize localIp = _localIp;
@synthesize servicePort = _servicePort;
@synthesize delegate = _delegate;

- (NSData*)getPeerInnerData {
    return NULL;
}

- (void)setPeerInnerData:(NSData*)data {
    
}

- (STPeer*)createPeerByData:(NSData*)data withLocalIp:(NSString*)ip withLocalPort:(int)port {
    STPeer* peer = [[STPeer alloc]init];
    peer.localIp = ip;
    peer.servicePort = port;
    [peer setPeerInnerData:data];
    
    return peer;
}

- (STPeer*)init {
    if (self = [super init]) {
        _localIp = @"127.0.0.1";
        _servicePort = DEFAULT_PORT;
        _delegate = NULL;
    }
    return self;
}

- (BOOL)setup {
    if (m_udp) {
        STLog(@"setup: error! udp socket has been setup before!");
        return NO;
    }
    
    m_udp = [[STUDPSocket alloc]initWithBroadcast:YES];
    m_udp.localPort = self.servicePort;
    m_udp.delegate = self;
    [m_udp open];
    
    return m_udp.isValidate;
}

- (void)tearDown {
    if (m_udp) {
        [m_udp close];
        m_udp = NULL;
        
        // 清空
        if (m_dictPeerInfo) {
            m_dictPeerInfo = NULL;
        }
    }
}

- (void)searchPeer {
    [self sendMessageTo:DEFAULT_BROADCAST_IP withMessageHead:emSearch];
}

- (void)dealloc {
    [self tearDown];
}

- (void)sendMessageTo:(NSString*)remoteIp withMessageHead:(STPEERHEADTYPE)head {
    
    assert(remoteIp);
    
    if (!m_udp || !m_udp.isValidate) {
        STLog(@"sendMessageTo: error! udp socket has not been initialize correctly!");
        return;
    }
    
    int32_t type = (int32_t)head;
    NSMutableData* data = [[NSMutableData alloc]initWithBytes:&type length:sizeof(int32_t)];
    
    if (head != emRemove) {     // 删除时，不需要带本地的信息数据
        NSData* msg = [self getPeerInnerData];
        if (msg) {
            [data appendData:msg];
        }
    }
    
    [m_udp send:data toIp:remoteIp toPort:self.servicePort];
}

#pragma recieve data from udp port
- (void)onDataRecieve:(NSData*)data withRemoteIp:(NSString *)ip withRemotePort:(int)port {
    assert(data && ip && (port > 0));
    
    if ([ip isEqual:self.localIp]) {
        return;                         // 不会处理自己发给自己的消息的
    }
    
    const void* ptrData = data.bytes;
    int32_t length = (int32_t)data.length;
    
    if (length < sizeof(int32_t)) {
        STLog(@"onDataRecieve: error! recieve data struct error!");
        return;
    }
    
    int32_t head = *((int32_t*)ptrData);
    ptrData += sizeof(int32_t);
    
    int32_t leftDataLength = length - sizeof(int32_t);
    STPeer* remotePeer = NULL;
    NSData* temp = NULL;
    if (leftDataLength > 0) {
        temp = [[NSData alloc]initWithBytes:ptrData length:leftDataLength];
    }
    remotePeer = [self createPeerByData:temp withLocalIp:ip withLocalPort:port];
    
    switch(head) {
        case emSearch:      // 被搜到了-_-!别人家的搜索
            [self addSearchPeer:remotePeer];
            [self sendMessageTo:ip withMessageHead:emAdd];
            if (self.delegate) {
                [self.delegate onRemotePeerSearch:self withRemotePeerIp:ip];
            }
            break;
        case emAdd:         // 搜到其它机器的回复^_^ 自已家的搜索
            [self addResponsePeer:remotePeer];
            if (self.delegate) {
                [self.delegate onRemotePeerAdd:self withRemotePeerIp:ip];
            }
            break;
        case emRemove:
            if (self.delegate) {
                [self.delegate onRemotePeerRemove:self withRemotePeerIp:ip];
            }
            [self removeResponsePeer:remotePeer];
            break;
        case emNone:
        default:
            break;
    }
}

#pragma private peer information maintain operations
- (void)addSearchPeer:(STPeer*)peer {
    if (!peer) {
        return;
    }
    
    if (!m_dictPeerInfo) {
        m_dictPeerInfo = [[NSMutableDictionary alloc]init];
    }
    
    NSMutableDictionary* dictionary = (NSMutableDictionary*)m_dictPeerInfo;
    [dictionary setObject:peer forKey:peer.localIp];
}

- (void)removeSearchPeer:(STPeer*)peer {
    if (!peer) {
        return;
    }
    
    if (m_dictPeerInfo) {
        NSMutableDictionary* dictionary = (NSMutableDictionary*)m_dictPeerInfo;
        [dictionary removeObjectForKey:peer.localIp];
    }
}

- (void)addResponsePeer:(STPeer*)peer {
    if (!peer) {
        return;
    }
    
    if (!m_dictPeerInfo) {
        m_dictPeerInfo = [[NSMutableDictionary alloc]init];
    }
    
    NSMutableDictionary* dictionary = (NSMutableDictionary*)m_dictPeerInfo;
    [dictionary setObject:peer forKey:peer.localIp];
}

- (void)removeResponsePeer:(STPeer*)peer {
    if (!peer) {
        return;
    }
    
    if (m_dictPeerInfo) {
        NSMutableDictionary* dictionary = (NSMutableDictionary*)m_dictPeerInfo;
        [dictionary removeObjectForKey:peer.localIp];
    }
}

- (STPeer*)getPeerFromIp:(NSString*)ip {
    if (!ip) {
        return NULL;
    }
    
    return [m_dictPeerInfo objectForKey:ip];
}

@end
