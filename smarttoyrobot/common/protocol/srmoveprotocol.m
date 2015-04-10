//
//  srmoveprotocol.m
//  smarttoyrobot
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "srmoveprotocol.h"

@implementation SRMoveProtocol

+ (SRMoveProtocol*) createMoveProtocol:(int)type {
    return (SRMoveProtocol*)[[STBasicProtocol alloc] initWithType:type];
}

@end
