/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript:
 */

#import "srtcpreciever.h"
#import "srviewcontroller.h"
#import "srcommander.h"
#import "misc/stlog.h"

@interface SRTCPReciever () {
    SRViewController* m_controller;
}
@end

@implementation SRTCPReciever

- (SRTCPReciever*)initWithViewController:(SRViewController*)controller {
    if (self = [super init]) {
        m_controller = controller;
    }
    return self;
}

- (void)onRecieve:(STTCPSocket *)socket withStream:(NSInputStream *)stream {
    
}

- (void)onRecieveEnd:(STTCPSocket *)socket {
    STLog(@"receive end");
}

- (void)onRecieveError:(STTCPSocket *)socket withError:(NSString *)errCode {
    STLog(@"recieve error when connect to other tcp socket!");
}

@end
