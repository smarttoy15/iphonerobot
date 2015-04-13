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
#import "network/protocol/stprotocol.h"
#import "stlog.h"
#import "stutils.h"

typedef struct {
    UInt32 length; // data的数据长度
    char data[0];
} _STTransferFormat;

@implementation STBasicProtocol

@synthesize type = _type;

- (STBasicProtocol*)init {
    if (self = [super init]) {
        _type = -1;
    }
    return self;
}

- (STBasicProtocol*)initWithType:(int)type {
    if (self = [super init]) {
        _type = type;
    }
    
    return self;
}

- (NSData*)getContentData {
    STLog(@"wanning: you have to override this method");
    return NULL;
}
- (NSData*)getTransferData {
    _STTransferFormat* info;
    
    NSData* data = [self getContentData];
    UInt32 dataLength = data ? [data length] : 0;
    dataLength += sizeof(UInt32); // plus the type area
    
    info = malloc(dataLength + sizeof(_STTransferFormat));
    info->length = dataLength;
    *(UInt32*)info->data = self.type;

    if (data) {
        memcpy(info->data + sizeof(UInt32), data.bytes, [data length]);
    }
    
    BTL_ENDIAN(info->length, UInt32);
    BTL_ENDIAN(info->data, UInt32);
    NSData* ret = [[NSData alloc]initWithBytes:info length:(dataLength + sizeof(_STTransferFormat))];
    free(info);
    
    return ret;
}

- (void)setContentData:(NSData*)data {
    STLog(@"you have to override this method");
}

- (void)setTransferData:(NSData*)data {
    assert([data length] >= sizeof(_STTransferFormat));
    
    const _STTransferFormat* info = (const _STTransferFormat*)data.bytes;
    LTB_ENDIAN(info->length, UInt32);
    
    if ((info->length + sizeof(UInt32)) > [data length] || info->length < sizeof(UInt32)) {
        STLog(@"error! Transfer data length invalide!");
        return;
    }
    
    if (info->length == 0 ) {
        STLog(@"warning: transfer data is empty");
        return;
    }
    
    UInt32 t = *(UInt32*)info->data;
    LTB_ENDIAN(t, UInt32);
    _type = (int)t;
    if (info->length > sizeof(UInt32)) {
        NSData* contentData = [[NSData alloc]initWithBytes:info->data + sizeof(UInt32) length:(info->length - sizeof(UInt32))];
        [self setContentData:contentData];
    }
}

@end