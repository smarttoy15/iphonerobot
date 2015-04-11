//
//  STTTCPClientHandler.m
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "stttcpclienthandler.h"
#import "sttsocketviewcontroller.h"

@interface STTTCPClientHandler () {
    STTSocketViewController* m_controller;
}

@end

@implementation STTTCPClientHandler

- (STTTCPClientHandler*)initWithViewController:(STTSocketViewController*)controller {
    if (self = [super init]) {
        m_controller = controller;
    }
    
    return self;
}

- (void)onConnected:(STTCPSocket *)TCPSocket {
    [m_controller appendMessage:[NSString stringWithFormat:@"socket %d connected!", TCPSocket.socketId]];
}

- (void)onDisconnected:(STTCPSocket *)TCPSocket {
    [m_controller appendMessage:[NSString stringWithFormat:@"socket %d disconnected!", TCPSocket.socketId]];
}

@end
