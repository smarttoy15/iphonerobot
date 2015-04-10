//
//  srmoveprotocol.h
//  smarttoyrobot
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//
#import "network/protocol/stprotocol.h"

@interface SRMoveProtocol : STBasicProtocol
+ (SRMoveProtocol*) createMoveProtocol:(int)type;
@end
