//
//  SRAudioProtocol.m
//  smarttoyrobot
//
//  Created by 张唯 on 15-4-28.
//  Copyright (c) 2015年 smarttoy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "sraudioprotocol.h"

@implementation SRAudioProtocol

- (SRAudioProtocol*)initWithType:(int)type {
    self = [super initWithType:type];
    return self;
}

- (NSData*) getContentData {
    return NULL;
}

- (void)setContentData:(id)data {
    
}

@end
