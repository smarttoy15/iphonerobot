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
#import "misc/stutils.h"
#import "sttdevice.h"

@interface STTDevice()
- (NSData*)getDataFromString:(NSString*)string;
- (NSString*)getStringFromBytes:(const void**)pData withLength:(UInt32)length;
@end

@implementation STTDevice

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize imageUrl = _imageUrl;

- (NSData*)getDataFromString:(NSString*)string {
    UInt32 length = string ? (UInt32)[string length] : 0;
    if (length != 0) {
        BTL_ENDIAN(length, UInt32);
    }
    NSMutableData* data = [[NSMutableData alloc]initWithBytes:&length length:sizeof(length)];
    if (string) {
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return data;
}

- (NSString*)getStringFromBytes:(const void**)pData withLength:(UInt32)length {
    assert(pData && length >= sizeof(UInt32));
    
    NSString* bRet = NULL;
    
    const void* bytes = *pData;
    UInt32 count = *(UInt32*)bytes;
    LTB_ENDIAN(count, UInt32);
    bytes += sizeof(UInt32);
    
    if ((length - sizeof(UInt32)) < count) {
        STLog(@"error! argument data has an incorrect length!");
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
    if (!data) {
        return;
    }
    
    do {
        const void* ptrData = data.bytes;
        UInt32 leftLength = (UInt32)[data length];
        if (leftLength < sizeof(UInt32)) {
            STLog(@"read title error!");
            break;
        }
        const void* ptrLast = ptrData;
        self.title = [self getStringFromBytes:&ptrData withLength:leftLength];
        leftLength -= ptrData - ptrLast;

        if (leftLength < sizeof(UInt32)) {
            STLog(@"read subTtitle error");
            break;
        }
        ptrLast = ptrData;
        self.subTitle = [self getStringFromBytes:&ptrData withLength:leftLength];
        leftLength -= ptrData - ptrLast;
        
        if (leftLength < sizeof(UInt32)) {
            STLog(@"read imget error");
            break;
        }
        ptrLast = ptrData;
        self.imageUrl = [self getStringFromBytes:&ptrData withLength:leftLength];
        leftLength -= ptrData - ptrLast;
    } while(0);
}

- (STPeer*)createPeerByData:(NSData *)data withLocalIp:(NSString *)ip withLocalPort:(int)port {
    STTDevice* device = [[STTDevice alloc]init];
    device.servicePort = port;
    device.localIp = ip;
    [device setPeerInnerData:data];
    return device;
}

@end
