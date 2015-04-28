/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 摄像头数量相关协议
 
 Modified:
 */

#import <Foundation/Foundation.h>
#import "srcameraInfoprotocol.h"

@implementation SRCameraInfoProtocol

- (SRCameraInfoProtocol*) initWithType:(int)type {
    self = [super initWithType:type];
    return self;
}

- (void) setContentData:(id)data {
    
}

- (NSData*) getContentData {
    return NULL;
}

@end
