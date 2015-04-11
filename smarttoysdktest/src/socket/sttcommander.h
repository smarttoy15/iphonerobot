//
//  STTCommander.h
//  smarttoysdktest
//
//  Created by newma on 4/6/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STTCommander : NSObject

+ (NSData*) getCommandTransferData:(NSData*)data;
+ (NSData*) getCommandDataFromInputStream:(NSInputStream*)stream;

@end
