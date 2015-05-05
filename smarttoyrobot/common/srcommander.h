/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript:
 */


#import <Foundation/Foundation.h>
#import "protocol/srtextprotocol.h"

@interface SRCommander : NSObject

+ (NSData*) getCommandTransferData:(NSData*)data;
+ (NSData*) getCommandDataFromInputStream:(NSInputStream*)stream;

+ (SRTextProtocol*) getStringPorotocolData:(NSString*)string;
+ (SRTextProtocol*) getStringProtocolFromInputStream:(NSInputStream*)stream;

@end
