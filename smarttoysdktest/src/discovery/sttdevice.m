//
//  SRDevice.m
//  smarttoyrobot
//
//  Created by newma on 3/18/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-17 15:07
 Descript: Socket在读取数据时的回调函数
 */

#import <Foundation/Foundation.h>
#import "misc/stlog.h"
#import "sttdevice.h"

@interface STTDevice()
- (NSData*)getDataFromString:(NSString*)string;
- (NSString*)getStringFromBytes:(const void**)pData withLength:(int32_t)length;
@end

@implementation STTDevice

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize imageUrl = _imageUrl;

- (NSData*)getDataFromString:(NSString*)string {
    int32_t length = string ? (int32_t)[string length] : 0;
    NSMutableData* data = [[NSMutableData alloc]initWithBytes:&length length:sizeof(length)];
    if (string) {
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return data;
}

- (NSString*)getStringFromBytes:(const void**)pData withLength:(int32_t)length {
    assert(pData && length >= sizeof(int32_t));
    
    NSString* bRet = NULL;
    
    const void* bytes = *pData;
    int32_t count = *(int32_t*)bytes;
    bytes += sizeof(int32_t);
    
    if ((length - sizeof(int32_t)) < count) {
        STLog(@"getStringFromBytes: error! argument data has an incorrect length!");
        return NULL;
    }
    
    if (count > 0) {
        bRet = [[NSString alloc]initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
        bytes += count;
    }
    
    *pData = bytes;
    return bRet;
}

- (NSData*)getPeerInnerData {
    NSMutableData* data = [[NSMutableData alloc]initWithData:[self getDataFromString:self.title]];
    [data appendData:[self getDataFromString:self.subTitle]];
    [data appendData:[self getDataFromString:self.imageUrl]];
    
    return data;
}

- (void)setPeerInnerData:(NSData *)data {
    const void* ptrData = data.bytes;
    int32_t leftLength = (int32_t)[data length];
    
    self.title = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - (const void*)data.bytes;
    self.subTitle = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - (const void*)data.bytes;
    self.imageUrl = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - (const void*)data.bytes;
}

- (STPeer*)createPeerByData:(NSData *)data withLocalIp:(NSString *)ip withLocalPort:(int)port {
    STTDevice* device = [[STTDevice alloc]init];
    device.servicePort = port;
    device.localIp = ip;
    [device setPeerInnerData:data];
    return device;
}

@end
