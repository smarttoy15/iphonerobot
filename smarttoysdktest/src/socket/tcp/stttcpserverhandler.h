//
//  STTTCPServerHandler.h
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "socket/sttcpserver.h"

@class STTSocketViewController;

@interface STTTCPServerHandler : NSObject<STTCPServerHandler>

- (STTTCPServerHandler*)initWithViewController:(STTSocketViewController*)controller;

@end
