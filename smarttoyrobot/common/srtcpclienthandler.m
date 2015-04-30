/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript:
 */

#import "srtcpclienthandler.h"
#import "srviewcontroller.h"

@interface SRTCPClientHandler () {
    SRViewController* m_controller;
}

@end

@implementation SRTCPClientHandler

- (SRTCPClientHandler*)initWithViewController:(SRViewController*)controller {
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
