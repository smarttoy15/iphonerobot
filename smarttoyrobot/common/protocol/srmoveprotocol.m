/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 移动相关协议
 
 Modified:
 */

#import <Foundation/Foundation.h>
#import "srmoveprotocol.h"


@implementation SRMoveProtocol

- (SRMoveProtocol*)initWithType:(int)type {
    self = [super initWithType:type];
    return self;
}

- (NSData*) getContentData {
    return NULL;
}

- (void)setContentData:(id)data {
    
}

@end
