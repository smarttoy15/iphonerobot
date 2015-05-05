/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript:
 */


#import <Foundation/Foundation.h>
#import "socket/sttcpsocket.h"

@class SRViewController;

@interface SRTCPClientHandler : NSObject<STTCPSocketHandler>

- (SRTCPClientHandler*)initWithViewController:(SRViewController*)controller;

@end
