//
//  UDPReciever.m
//  test_proj
//
//  Created by newma on 2/28/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: STUDPReciever的实现
 */

#import <Foundation/Foundation.h>
#include "socket/studpsocket.h"
#import <CFNetwork/CFNetwork.h>
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <fcntl.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/types.h>

#define DEFAULT_UDP_PORT 65535

@interface STUDPSocket()
{
    CFSocketRef m_socket;
    CFRunLoopSourceRef m_loopSource;
    
    BOOL m_isConnected;
}

- (BOOL)setSocketOption:(int)socketFD;
- (BOOL)bindSocket:(int)socketFD;
- (BOOL)connect:(int)socketFD withRemoteIp:(NSString*)remoteIp withRemotePort:(int)remotePort;
- (BOOL)setupRunloop:(int)socketFD;
- (void)tearDownRunloop;
@end

void onUDPDataCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    
    STUDPSocket* socket = nil;
    if (info) {
        socket = (__bridge STUDPSocket*)info;
    }
    
    if (callbackType == kCFSocketDataCallBack) {
        
        CFDataRef cfData = (CFDataRef)data;
        NSData* recData = (__bridge_transfer NSData*)cfData;
        
        if (socket.delegate) {
            [socket.delegate onDataRecieve:recData];
        }
        
        return;
    }
}

@implementation STUDPSocket

@synthesize localPort = _localPort;
@synthesize remoteIp = _remoteIp;
@synthesize remotePort = _remotePort;
@synthesize isValidate = _isValidate;
@synthesize delegate = _delegate;

- (STUDPSocket*)init {
    if (self = [super init]) {
        _localPort = DEFAULT_UDP_PORT;
        _remoteIp = NULL;
        _remotePort = DEFAULT_UDP_PORT;
        _isValidate = NO;
        _delegate = NULL;
        
        m_socket = NULL;
        m_loopSource = NULL;
        m_isConnected = false;
    }
    return self;
}

- (BOOL)open {
    return [self openWithRemoteIp:NULL withRemotePort:0];
}

- (BOOL)openWithRemoteIp:(NSString*)remoteIp withRemotePort:(int)remotePort {
    BOOL bRet = NO;
    int socketFD = 0;
    
    do {
        socketFD = socket(AF_INET, SOCK_DGRAM, 0);
        if (socketFD == 0) {
            NSLog(@"error: init udp socket failed!");
            break;
        }
        
        if (![self setSocketOption:socketFD]) {
            break;
        }
        
        if (![self bindSocket:socketFD]) {
            NSLog(@"error: bind socket failed!");
            break;
        }
        
        // connect
        if (remoteIp && remotePort > 0) {
            [self connect:socketFD withRemoteIp:remoteIp withRemotePort:remotePort];
        }
        
        if (![self setupRunloop:socketFD]) {
             NSLog(@"error: step up runloop failed!");
             break;
        }
        
        _isValidate = YES;
        
        bRet = true;
    } while(false);
    
    if (!bRet && socketFD) {
        close(socketFD);
    }
    
    return bRet;
}

- (BOOL)send:(NSData*)data toIp:(NSString*)ip toPort:(int)port {
    self.remoteIp = ip;
    self.remotePort = port;
    
    m_isConnected = false;  // 使用此函数后，之前的connect函数就报废了
    return [self send:data];
}
- (BOOL)send:(NSData*)data {
    
    if (!self.isValidate) {
        NSLog(@"send: udp socket hasn't been initialized!");
        return false;
    }
    
    if (self.remotePort <= 0 || self.remoteIp == nil || [self.remoteIp isEqual:@""]) {
        NSLog(@"remote ip or remote port hasn't initialized correctly!");
        return false;
    }
    
    CFDataRef serverAddr = NULL;
    
    if (!m_isConnected) {
        struct sockaddr_in server;
        memset(&server, 0, sizeof(server));
        server.sin_len = sizeof(server);
        server.sin_family=AF_INET;
        server.sin_port=htons(self.remotePort); ///server的监听端口
        server.sin_addr.s_addr=inet_addr(self.remoteIp.UTF8String); ///server的地址
    
        serverAddr = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&server, sizeof(server));
    }
    
    // 如果之前已经connect的话，serverAddr就为nil;
    CFSocketError error = CFSocketSendData(m_socket, serverAddr, (__bridge_retained CFDataRef)data,0);
    return error == kCFSocketSuccess;
}
- (BOOL)send:(void*)data withLength:(long)length {
    NSData* nData = [NSData dataWithBytes:data length:length];
    return [self send:nData];
}

- (void)close {
    int socketFD = -1;
    if (m_socket != nil) {
        socketFD = CFSocketGetNative(m_socket);
        [self tearDownRunloop];
        if (socketFD > 0) {
            close(socketFD);
        }
    }
}

- (BOOL)setSocketOption:(int)socketFD {
    int status;
    // Set socket options
    status = fcntl(socketFD, F_SETFL, O_NONBLOCK);
    if (status == -1) {
        NSLog(@"error: set socket O_NONBLOCK option failed");
        return false;
    }
    
    int reuseaddr = 1;
    status = setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof(reuseaddr));
    if (status == -1) {
        NSLog(@"error: set socket SO_REUSEADDR option failed!");
        return false;
    }
    
    int nosigpipe = 1;
    status = setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    if (status == -1) {
        NSLog(@"error: set socket SO_NOSIGPIPE option failed");
        return false;
    }
    
    return true;
}

- (BOOL)bindSocket:(int)socketFD {
    int status = -1;
    struct sockaddr_in local;
    memset(&local, 0, sizeof(local));
    local.sin_len = sizeof(local);
    local.sin_family = AF_INET;
    local.sin_port = htons(self.localPort); ///监听端口
    local.sin_addr.s_addr = INADDR_ANY; ///本机
    status = bind(socketFD,(struct sockaddr*)&local,sizeof local);

    return status == 0 ? true : false;
}

- (BOOL)connect:(int)socketFD withRemoteIp:(NSString*)remoteIp withRemotePort:(int)remotePort {
    if (!remoteIp || [remoteIp length] == 0 || remotePort <= 0) {
        NSLog(@"connect: invalid argument of remote address");
        return false;
    }
    
    self.remoteIp = remoteIp;
    self.remotePort = remotePort;
    
    int status = -1;
    struct sockaddr_in remote;
    int len = sizeof(remote);
    memset(&remote, 0, len);
    remote.sin_len = sizeof(remote);
    remote.sin_family = AF_INET;
    remote.sin_port = htons(remotePort); ///监听端口
    remote.sin_addr.s_addr = inet_addr([remoteIp UTF8String]); ///本机
    status = connect(socketFD, (const struct sockaddr*)&remote, len);
    
    m_isConnected = status == 0 ? true : false;
    return m_isConnected;
}

- (BOOL)setupRunloop:(int)socketFD {
    CFSocketContext context = {
        0,
        (__bridge void*)self,
        NULL,
        NULL,
        NULL
    };
    
    m_socket = CFSocketCreateWithNative(kCFAllocatorDefault, socketFD, kCFSocketDataCallBack, onUDPDataCallback, &context);
    if (!m_socket) {
        NSLog(@"error: create CFSocketRef failed!");
        return false;
    }
    
    // 设置socket的相关属性
    CFOptionFlags sockopt = CFSocketGetSocketFlags(m_socket);
    sockopt |= kCFSocketCloseOnInvalidate | kCFSocketAutomaticallyReenableReadCallBack;
    CFSocketSetSocketFlags(m_socket, sockopt);
    
    m_loopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), m_loopSource, kCFRunLoopDefaultMode);
    
    return true;
}

- (void)tearDownRunloop {
    if (m_loopSource != nil) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), m_loopSource, kCFRunLoopDefaultMode);
        CFRelease(m_loopSource);
        m_loopSource = nil;
    }
    
    if (m_socket != nil) {
        CFSocketInvalidate(m_socket);
        CFRelease(m_socket);
        m_socket = nil;
    }
}

@end