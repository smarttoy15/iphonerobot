//
//  STTUDPReciever.h
//  smarttoysdktest
//
//  Created by newma on 4/5/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "socket/studprecieve_i.h"

@class STTSocketViewController;

@interface STTUDPReciever : NSObject<STUDPSocketHandler>

- (STTUDPReciever*)initWithViewController:(STTSocketViewController*)controller;

@end
