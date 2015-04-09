//
//  TCPServer.m
//  test_proj
//
//  Created by newma on 2/9/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/* 
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript:STTCPServer的实现
*/

#import <Foundation/Foundation.h>

#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "socket/sttcpserver.h"

@interface STTCPServer() <NSStreamDelegate, STTCPSocketHandler>
{
    NSMutableDictionary* m_dictionary;
    
    CFRunLoopSourceRef m_runloopSource;
    CFSocketRef m_serverSocket;
    
    int socket_session_id_gen;
}

- (BOOL) setupSocket;
- (void) onTCPAccept:(CFSocketRef)serverSocket withAcceptNativeScoketHandler:(CFSocketNativeHandle)socketHandler;
@end

void onTCPAcceptCallback(CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
    if (callbackType == kCFSocketAcceptCallBack) {
        if (data == NULL) {  // data is a pointer to a CFSocketNativeHandle;
            NSLog(@"Error: TCP server accept has ocurred an error!");
            return;
        }
    
        STTCPServer* server = (__bridge STTCPServer*)info;
        [server onTCPAccept:s withAcceptNativeScoketHandler:*(CFSocketNativeHandle*)data];
    }
}

@implementation STTCPServer

@synthesize port = _port;
@synthesize delegate = _delegate;
@synthesize readDelegate = _readDelegate;
@synthesize isWorking = _isWorking;

- (STTCPServer*)initWithPort:(int)port {
    self = [super init];
    
    if (self != nil) {
        _port = port;
        socket_session_id_gen = -1;
        m_dictionary = nil;
        _isWorking = false;
    }
    
    return self;
}

- (BOOL)setupSocket {
    CFSocketContext context = {
        0,
        (__bridge void*)self,
        NULL,
        NULL,
        NULL
    };
    
    CFSocketRef socket = CFSocketCreate(NULL, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, onTCPAcceptCallback, &context);
    
    if (!socket) {
        NSLog(@"Create socket failed!");
        return NO;
    }
    
    int optval = 1;
    setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, // 允许重用本地地址和端口
               (void *)&optval, sizeof(optval));
    
    // Socket 地址
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET; /* Address family */
    sin.sin_port = htons(_port); /* Or a specific port */
    sin.sin_addr.s_addr= INADDR_ANY;
    
    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(sin));
    
    if (kCFSocketSuccess != CFSocketSetAddress(socket, sincfd)) {
        NSLog(@"Bind to address failed!");
        if (socket) {
            CFRelease(socket);
            socket = NULL;
        }
        return NO;
    }
    
    CFRelease(sincfd);
    
    m_serverSocket = socket;
    m_runloopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, m_serverSocket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), m_runloopSource, kCFRunLoopDefaultMode);
    CFRelease(m_runloopSource);
    
    if (self.delegate) {
        [self.delegate onServerStart:self];
    }
    
    return YES;
}

- (BOOL)start {
    if (!_isWorking) {
        _isWorking = [self setupSocket];
    }
    return self.isWorking;
}

- (void)close {
    if (m_runloopSource) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), m_runloopSource, kCFRunLoopDefaultMode);
        m_runloopSource = nil;
    }
    if (m_serverSocket) {
        CFSocketInvalidate(m_serverSocket);
        m_serverSocket = nil;
    }
    _isWorking = NO;
    
    if (self.delegate) {
        [self.delegate onServerClose:self];
    }
    
    [self removeAllSessions];
}

- (void) onTCPAccept:(CFSocketRef)serverSocket withAcceptNativeScoketHandler:(CFSocketNativeHandle)socketHandler {
    STTCPSocket* session = [[STTCPSocket alloc]initWithSocket:socketHandler withId:++socket_session_id_gen];
    session.delegate = self;

    if (!m_dictionary) {
        m_dictionary = [NSMutableDictionary dictionary];
    }
    
    [m_dictionary setObject:session forKey:[NSNumber numberWithInt:session.socketId]];
}

- (STTCPSocket*)getSessionById:(int)sessionId {
    if (!m_dictionary) {
        return nil;
    }
    
    return [m_dictionary objectForKey:[NSNumber numberWithInt:sessionId]];
}

- (long)getSessionCount {
    return !m_dictionary ? 0 : [[m_dictionary allKeys] count];
}

- (void)removeSessionById:(int)sessionId {
    if (!m_dictionary) {
        return;
    }
    
    STTCPSocket* session = [self getSessionById:sessionId];
    if (session) {
        [session close];
        [m_dictionary removeObjectForKey:[NSNumber numberWithInt:sessionId]];
    }
}

- (void)removeAllSessions {
    if (!m_dictionary) {
        return;
    }
    
    [m_dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        STTCPSocket* session = (STTCPSocket*)obj;
        [session close];
    }];
    
    [m_dictionary removeAllObjects];
    m_dictionary = nil;
}

- (void)onConnected:(STTCPSocket*)session {
    
    session.readDelegate = self.readDelegate;
    
    if (_delegate != nil) {
        [_delegate onAccept:self withSocket:session];
    }
}

- (void)onDisconnected:(STTCPSocket*)session {
    if (_delegate != nil) {
        [_delegate onSocketClose:self withSocket:session];
    }
}

@end
