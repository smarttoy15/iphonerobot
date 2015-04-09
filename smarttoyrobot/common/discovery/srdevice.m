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
#import "SRDevice.h"

@interface SRDevice()
- (NSData*)getDataFromString:(NSString*)string;
- (NSString*)getStringFromBytes:(const void**)pData withLength:(int32_t)length;
@end

@implementation SRDevice

@synthesize title = _title;
@synthesize subTitle = _subTitle;
@synthesize imageUrl = _imageUrl;

- (NSData*)getDataFromString:(NSString*)string {
    assert(string);
    int32_t length = (int32_t)[string length];
    NSMutableData* data = [[NSMutableData alloc]initWithBytes:&length length:sizeof(length)];
    [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}

- (NSString*)getStringFromBytes:(const void**)pData withLength:(int32_t)length {
    assert(pData && length > sizeof(int32_t));
    
    const void* bytes = *pData;
    int32_t count = *(int32_t*)bytes;
    bytes += sizeof(int32_t);
    
    if ((length - sizeof(int32_t)) < count) {
        STLog(@"getStringFromBytes: error! argument data has an incorrect length!");
        return NULL;
    }
    
    NSString* bRet = [[NSString alloc]initWithBytes:bytes length:count encoding:NSUTF8StringEncoding];
    bytes += count;
    
    *pData = bytes;
    return bRet;
}

- (NSData*)getContentData {
    NSMutableData* data = [[NSMutableData alloc]initWithData:[self getDataFromString:self.title]];
    [data appendData:[self getDataFromString:self.subTitle]];
    [data appendData:[self getDataFromString:self.imageUrl]];
    
    return data;
}

- (void)parseContentData:(NSData*)data {
    assert(data);
    const void* ptrData = data.bytes;
    const void* ptrHead = ptrData;
    int32_t leftLength = (int32_t)data.length;
    self.title = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - ptrHead;
    self.subTitle = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - ptrHead;
    self.imageUrl = [self getStringFromBytes:&ptrData withLength:leftLength];
    leftLength -= ptrData - ptrHead;
}

@end
