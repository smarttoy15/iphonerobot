//
//  STTCommander.h
//  smarttoysdktest
//
//  Created by newma on 4/6/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "protocol/stttextprotocol.h"

@interface STTCommander : NSObject

+ (NSData*) getCommandTransferData:(NSData*)data;
+ (NSData*) getCommandDataFromInputStream:(NSInputStream*)stream;

+ (STTTextProtocol*) getStringPorotocolData:(NSString*)string;
+ (STTTextProtocol*) getStringProtocolFromInputStream:(NSInputStream*)stream;

@end
