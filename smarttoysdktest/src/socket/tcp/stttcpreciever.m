//
//  STTTCPEventHandler.m
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "stttcpreciever.h"
#import "sttsocketviewcontroller.h"
#import "../sttcommander.h"

@interface STTTCPReciever () {
    STTSocketViewController* m_controller;
}
@end

@implementation STTTCPReciever

- (STTTCPReciever*)initWithViewController:(STTSocketViewController*)controller {
    if (self = [super init]) {
        m_controller = controller;
    }
    return self;
}

- (void)onRecieve:(STTCPSocket *)socket withStream:(NSInputStream *)stream {
    NSData* data = [STTCommander getCommandDataFromInputStream:stream];
    
    NSString* message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [m_controller appendMessage:message];
}

- (void)onRecieveEnd:(STTCPSocket *)socket {
    [m_controller appendMessage:@"recieve end!"];
}

- (void)onRecieveError:(STTCPSocket *)socket withError:(NSString *)errCode {
    [m_controller appendMessage:@"recieve error when connect to other tcp socket!"];
}

@end
