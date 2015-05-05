/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript:
 */

#import <Foundation/Foundation.h>
#import "socket/sttcprecieve_i.h"

@class SRViewController;

@interface SRTCPReciever : NSObject<STTCPRecieverInterface>

- (SRTCPReciever*)initWithViewController:(SRViewController*)controller;

@end
