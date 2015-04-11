//
//  STTTCPEventHandler.h
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "socket/sttcprecieve_i.h"

@class STTSocketViewController;

@interface STTTCPReciever : NSObject<STTCPRecieverInterface>

- (STTTCPReciever*)initWithViewController:(STTSocketViewController*)controller;

@end
