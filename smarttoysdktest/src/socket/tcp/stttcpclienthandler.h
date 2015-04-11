//
//  STTTCPClientHandler.h
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "socket/sttcpsocket.h"

@class STTSocketViewController;

@interface STTTCPClientHandler : NSObject<STTCPSocketHandler>

- (STTTCPClientHandler*)initWithViewController:(STTSocketViewController*)controller;

@end
