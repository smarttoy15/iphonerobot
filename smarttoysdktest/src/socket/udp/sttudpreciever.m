//
//  STTUDPReciever.m
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttudpreciever.h"
#import "sttsocketviewcontroller.h"

@interface STTUDPReciever () {
    STTSocketViewController* m_controller;
}

@end

@implementation STTUDPReciever

- (STTUDPReciever*)initWithViewController:(STTSocketViewController*)controller {
    if (self = [super init]) {
        m_controller = controller;
    }
    
    return self;
}

- (void)onDataRecieve:(NSData *)data withRemoteIp:(NSString *)ip withRemotePort:(int)port {
    NSString* str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString* message = [NSString stringWithFormat:@"recieve string message \"%@\" from [ip:%@ port:%d]", str, ip, port];
    [m_controller appendMessage:message];
}

@end
