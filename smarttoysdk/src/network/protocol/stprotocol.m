//
//  stprotocol.m
//  smarttoysdk
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: 协议类
 */

#import <Foundation/Foundation.h>
#import "stlog.h"
#import "network/protocol/stprotocol.h"

typedef struct {
    int32_t length; // 整个数据的长度，其中type的长度也计算在内
    int32_t type;
    char data[0]; // 数据的长度为(length - sizeof(int32_t))
} _STTransferFormat;

@implementation STBasicProtocol

@synthesize type = _type;

- (STBasicProtocol*)initWithType:(int)type {
    if (self = [super init]) {
        _type = -1;
    }
    
    return self;
}

- (NSData*)getContentData {
    STLog(@"you have to override this method");
    return NULL;
}
- (NSData*)getTransferData {
    _STTransferFormat* info;
    int32_t length = sizeof(_STTransferFormat);
    
    NSData* data = [self getContentData];
    if (data) {
        length += [data length];
        info = malloc(length);
        info->length = length;
        info->type = self.type;
        memcpy(info->data, data.bytes, [data length]);
    } else {
        info = malloc(length);
        info->length = length;
        info->type = self.type;
    }
    
    NSData* ret = [[NSData alloc]initWithBytes:&info length:info->length];
    free(info);
    
    return ret;
}

- (void)setContentData:(NSData*)data {
    STLog(@"you have to override this method");
}

- (void)setTransferData:(NSData*)data {
    const _STTransferFormat* info = (const _STTransferFormat*)data.bytes;
    
    if (info->length != [data length]) {
        STLog(@"error! Data length not match!");
        return;
    }
    
    _type = info->type;
    if (info->length > sizeof(_STTransferFormat)) {
        NSData* contentData = [[NSData alloc]initWithBytes:info->data length:(info->length - sizeof(_STTransferFormat))];
        [self setTransferData:contentData];
    }
}

@end