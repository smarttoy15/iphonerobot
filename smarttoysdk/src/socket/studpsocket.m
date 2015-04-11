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
#import "network/stnetwork.h"
#import "socket/studpsocket.h"
#import <CFNetwork/CFNetwork.h>
#import <UIKit/UIKit.h>
#import <arpa/inet.h>
#import <fcntl.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <net/if.h>
#import <sys/socket.h>
#import <sys/types.h>

#import "misc/stlog.h"

#define DEFAULT_UDP_PORT 5008

@interface STUDPSocket()
{
    CFSocketRef m_socket;
    CFRunLoopSourceRef m_loopSource;
    
    BOOL m_isConnected;
}
- (NSData*) getSendAddrData:(NSString*)ip withPort:(UInt16)port;

- (BOOL)setSocketOption:(int)socketFD;
- (BOOL)bindSocket:(int)socketFD;
- (BOOL)connect:(int)socketFD withRemoteIp:(NSString*)remoteIp withRemotePort:(int)remotePort;
- (BOOL)setupRunloop:(int)socketFD;
- (void)tearDownRunloop;

- (void)onReadCallback;
- (void)onWriteCallback;
@end

void onUDPDataCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    
    STUDPSocket* socket = nil;
    if (info) {
        socket = (__bridge STUDPSocket*)info;
    }
 
    if (callbackType == kCFSocketWriteCallBack) {
        [socket onWriteCallback];
    }
    
    if (callbackType == kCFSocketReadCallBack) {
        [socket onReadCallback];
    }
}

@implementation STUDPSocket

@synthesize localPort = _localPort;
@synthesize remoteIp = _remoteIp;
@synthesize remotePort = _remotePort;
@synthesize isValidate = _isValidate;
@synthesize delegate = _delegate;
@synthesize canBroadcast = _canBroadcast;
@synthesize maxReceiveBufferLen = _maxReceiveBufferLen;

- (STUDPSocket*)init {
    if (self = [super init]) {
        _localPort = DEFAULT_UDP_PORT;
        _remoteIp = NULL;
        _remotePort = DEFAULT_UDP_PORT;
        _isValidate = NO;
        _delegate = NULL;
        _canBroadcast = NO;
        _maxReceiveBufferLen = MAX_UDP_PACKAGE_DATA_LENGTH;
        
        m_socket = NULL;
        m_loopSource = NULL;
        m_isConnected = false;
    }
    return self;
}

- (STUDPSocket*)initWithBroadcast:(BOOL)enableBroadcast {
    self = [self init];
    _canBroadcast = enableBroadcast;
    return self;
}

- (void)onWriteCallback {
    _isValidate = true;
}

- (void)onReadCallback {
    
    struct sockaddr_in sockaddr;
    socklen_t sockaddrLen = sizeof(sockaddr);
    
    NSData* buffData = nil;
    void* buff = (void*)malloc(self.maxReceiveBufferLen);
    size_t buffSize = self.maxReceiveBufferLen;
    
    ssize_t result = recvfrom(CFSocketGetNative(m_socket), buff, buffSize, 0, (struct sockaddr *)&sockaddr, &sockaddrLen);

    if(result > 0)
    {
        NSString* host = [STNetwork getIPv4StringFromIn_Addr:(in_addr_t)sockaddr.sin_addr.s_addr];
        UInt16 port = ntohs(sockaddr.sin_port);
        
        if (self.delegate) {
            buffData = [[NSData alloc]initWithBytesNoCopy:buff length:result];
            [self.delegate onDataRecieve:buffData withRemoteIp:host withRemotePort:port];
        }
    }
    
    if (buffData == nil) {
        free(buff);
    }
    
    CFSocketEnableCallBacks(m_socket, kCFSocketReadCallBack | kCFSocketWriteCallBack);
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
            STLog(@"error: init udp socket failed!");
            break;
        }
        
        if (![self setupRunloop:socketFD]) {
            STLog(@"error: step up runloop failed!");
            break;
        }
        
        if (![self setSocketOption:socketFD]) {
            break;
        }
        
        if (![self bindSocket:socketFD]) {
            STLog(@"error: bind socket failed!");
            break;
        }
        
        // connect
        if (remoteIp && remotePort > 0) {
            [self connect:socketFD withRemoteIp:remoteIp withRemotePort:remotePort];
        }
        
        //_isValidate = YES;
        
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

- (NSData*) getSendAddrData:(NSString*)ip withPort:(UInt16)port {
    NSString *portStr = [NSString stringWithFormat:@"%hu", port];
    
    struct addrinfo hints, *res, *res0;
        
    memset(&hints, 0, sizeof(hints));
    hints.ai_family   = PF_UNSPEC;
    hints.ai_socktype = SOCK_DGRAM;
    hints.ai_protocol = IPPROTO_UDP;
    // No passive flag on a send or connect
        
    int error = getaddrinfo([ip UTF8String], [portStr UTF8String], &hints, &res0);
        
    if(error) {
        STLog(@"get net address of %s:%u failed!", ip, port);
        return nil;
    }
        
    for(res = res0; res; res = res->ai_next)
    {
        if(res->ai_family == AF_INET)
        {
            return [[NSData alloc]initWithBytes:res->ai_addr length:res->ai_addrlen];
        }
    }
    freeaddrinfo(res0);
    return nil;
}

- (BOOL)send:(NSData*)data {
    BOOL bRet = false;
    if (!self.isValidate) {
        STLog(@"send: udp socket hasn't been initialized!");
        return bRet;
    }
    
    if (self.remotePort <= 0 || self.remoteIp == nil || [self.remoteIp isEqual:@""]) {
        STLog(@"remote ip or remote port hasn't initialized correctly!");
        return bRet;
    }
    
    ssize_t result = -1;
    if (!m_isConnected) {
        NSData* addr = [self getSendAddrData:self.remoteIp withPort:(UInt16)self.remotePort];
        if (addr) {
            result = sendto(CFSocketGetNative(m_socket), data.bytes, (size_t)[data length], 0, addr.bytes, (socklen_t)[addr length]);
        }
    } else {
        result = send(CFSocketGetNative(m_socket), data.bytes, (size_t)[data length], 0);
    }
    bRet = result >= 0 ? YES : NO;
    
    _isValidate = false;
    CFSocketEnableCallBacks(m_socket, kCFSocketReadCallBack | kCFSocketWriteCallBack);
    return bRet;
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
        STLog(@"error: set socket O_NONBLOCK option failed");
        return false;
    }
    
    int reuseaddr = 1;
    status = setsockopt(socketFD, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof(reuseaddr));
    if (status == -1) {
        STLog(@"error: set socket SO_REUSEADDR option failed!");
        return false;
    }
    
    int nosigpipe = 1;
    status = setsockopt(socketFD, SOL_SOCKET, SO_NOSIGPIPE, &nosigpipe, sizeof(nosigpipe));
    if (status == -1) {
        STLog(@"error: set socket SO_NOSIGPIPE option failed");
        return false;
    }
    
    if (self.canBroadcast) {
        int broadcast = self.canBroadcast;
        status = setsockopt(socketFD, SOL_SOCKET, SO_BROADCAST, (const void *)&broadcast, sizeof(broadcast));
        if (status == -1) {
            STLog(@"error: set socket SO_BROADCAST failed!");
            return false;
        }
    }
    return true;
}

- (BOOL)bindSocket:(int)socketFD {
    struct sockaddr_in local;
    memset(&local, 0, sizeof(local));
    local.sin_len = sizeof(local);
    local.sin_family = AF_INET;
    local.sin_port = htons(self.localPort); ///监听端口
    local.sin_addr.s_addr = htonl(INADDR_ANY);
    
    NSData* addrData = [NSData dataWithBytes:&local length:sizeof(local)];
    CFSocketError error = CFSocketSetAddress(m_socket, (__bridge CFDataRef)addrData);
    
    return error == kCFSocketSuccess;
}

- (BOOL)connect:(int)socketFD withRemoteIp:(NSString*)remoteIp withRemotePort:(int)remotePort {
    if (!remoteIp || [remoteIp length] == 0 || remotePort <= 0) {
        STLog(@"connect: invalid argument of remote address");
        return false;
    }
    
    self.remoteIp = remoteIp;
    self.remotePort = remotePort;
    
    NSData* addrData = [self getSendAddrData:self.remoteIp withPort:(UInt16)self.remotePort];
    if(!addrData) {
        return false;
    }
    
    CFSocketError error = CFSocketConnectToAddress(m_socket, (__bridge CFDataRef)addrData, (CFTimeInterval)0.0);
    
    m_isConnected = error == kCFSocketSuccess;
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
    
    m_socket = CFSocketCreateWithNative(kCFAllocatorDefault, socketFD, kCFSocketReadCallBack | kCFSocketWriteCallBack, onUDPDataCallback, &context);
    if (!m_socket) {
        STLog(@"error: create CFSocketRef failed!");
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