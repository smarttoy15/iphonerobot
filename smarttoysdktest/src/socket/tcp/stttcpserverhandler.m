//
//  STTTCPServerHandler.m
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "stttcpserverhandler.h"
#import "sttsocketviewcontroller.h"

@interface STTTCPServerHandler (){
    STTSocketViewController* m_controller;
}

@end

@implementation STTTCPServerHandler

- (STTTCPServerHandler*)initWithViewController:(STTSocketViewController*)controller {
    if (self = [super init]) {
        m_controller = controller;
    }
    
    return self;
}

- (void)onAccept:(STTCPServer *)server withSocket:(STTCPSocket *)socket {
    [m_controller appendMessage:[NSString stringWithFormat:@"accept socket %d", socket.socketId]];
}

- (void)onServerClose:(STTCPServer *)server {
    [m_controller appendMessage:@"server closed"];
}

- (void)onServerStart:(STTCPServer *)server {
    [m_controller appendMessage:@"server start"];
}

- (void)onSocketClose:(STTCPServer *)server withSocket:(STTCPSocket *)socket {
    [m_controller appendMessage:[NSString stringWithFormat:@"socket %d is closed!", socket.socketId]];
}

@end
