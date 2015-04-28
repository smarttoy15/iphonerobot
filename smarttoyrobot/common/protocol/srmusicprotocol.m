/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 播放音乐相关协议
 
 Modified:
 */


#import <Foundation/Foundation.h>
#import "srmusicprotocol.h"

@implementation SRMusicProtocol

- (SRMusicProtocol*) initWithType:(int)type {
    self = [super initWithType:type];
    return self;
}

- (NSData*) getContentData {
    return NULL;
}

- (void) setContentData:(NSData *)data {
    
}

@end
