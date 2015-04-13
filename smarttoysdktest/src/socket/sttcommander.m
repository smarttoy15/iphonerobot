//
//  STTCommander.m
//  smarttoysdktest
//
//  Created by newma on 4/6/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttcommander.h"
#import "misc/stlog.h"
#import "misc/stutils.h"

#define MAX_BUFFER_SIZE 1024

@implementation STTCommander

+ (NSData*) getCommandTransferData:(NSData*)data {
    assert(data);
    UInt32 length = (UInt32)[data length];
    BTL_ENDIAN(length, UInt32);
    
    NSMutableData* ret = [[NSMutableData alloc]initWithBytes:&length length:sizeof(length)];
    [ret appendData:data];
    return ret;
}

+ (NSData*) getCommandDataFromInputStream:(NSInputStream*)stream {
    assert(stream);
    UInt32 leftLen = 0;
    
    NSInteger readLen = [stream read:(uint8_t*)&leftLen maxLength:sizeof(leftLen)];
    
    if (readLen <= 0) {
        STLog(@"error! read stream command format error!");
    }
    LTB_ENDIAN(leftLen, UInt32);
    
    NSMutableData* ret = [NSMutableData alloc];
    uint8_t buffer[MAX_BUFFER_SIZE] = {0};
    
    while(leftLen > 0) {
        readLen = [stream read:buffer maxLength:(leftLen > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : leftLen)];
        
        if (readLen < 0) {
            STLog(@"error! read stream error, while read a command. command data is not complete!");
            return NULL;
        }
        
        [ret appendBytes:buffer length:readLen];
        
        leftLen -= readLen;
    }
    
    return ret;
}

+ (STTTextProtocol*) getStringPorotocolData:(NSString*)string {
    STTTextProtocol* pro = [[STTTextProtocol alloc] init];
    pro.text = string;
    return pro;
}

+ (STTTextProtocol*) getStringProtocolFromInputStream:(NSInputStream*)stream{
    assert(stream);
    UInt32 leftLen = 0;
    
    NSInteger readLen = [stream read:(uint8_t*)&leftLen maxLength:sizeof(leftLen)];
    
    if (readLen != sizeof(leftLen)) {
        STLog(@"error! read stream command format error!");
    }
    
    NSMutableData* ret = [NSMutableData alloc];
    uint8_t buffer[MAX_BUFFER_SIZE] = {0};
    [ret appendBytes:&leftLen length:sizeof(UInt32)];
    
    LTB_ENDIAN(leftLen, UInt32);
    while(leftLen > 0) {
        readLen = [stream read:buffer maxLength:(leftLen > MAX_BUFFER_SIZE ? MAX_BUFFER_SIZE : leftLen)];
        
        if (readLen < 0) {
            STLog(@"error! read stream error, while read a command. command data is not complete!");
            return NULL;
        }
        
        [ret appendBytes:buffer length:readLen];
        
        leftLen -= readLen;
    }
    
    STTTextProtocol* pro = [[STTTextProtocol alloc]init];
    [pro setTransferData:ret];
    return pro;
}

@end
