//
//  STTCommander.m
//  smarttoysdktest
//
//  Created by newma on 4/6/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttcommander.h"
#import "misc/stlog.h"

#define MAX_BUFFER_SIZE 1024

@implementation STTCommander

+ (NSData*) getCommandTransferData:(NSData*)data {
    assert(data);
    int32_t length = (int32_t)[data length];
    
    NSMutableData* ret = [[NSMutableData alloc]initWithBytes:&length length:sizeof(length)];
    [ret appendData:data];
    return ret;
}

+ (NSData*) getCommandDataFromInputStream:(NSInputStream*)stream {
    assert(stream);
    int32_t leftLen = 0;
    
    NSInteger readLen = [stream read:(uint8_t*)&leftLen maxLength:sizeof(leftLen)];
    
    if (readLen <= 0) {
        STLog(@"error! read stream command format error!");
    }
    
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

@end
