/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 机器人舞蹈相关协议
 
 Modified:
 */

#import <Foundation/Foundation.h>
#import "srdanceprotocol.h"

@implementation SRDanceProtocol

- (SRDanceProtocol*) initWithType:(int)type {
    self = [super initWithType:type];
    return self;
}

- (void) setContentData:(NSData *)data {
    
}

- (NSData*) getContentData {
    return NULL;
}

@end
