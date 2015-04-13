//
//  STTTextProtocol.m
//  smarttoysdktest
//
//  Created by newma on 4/13/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "stttextprotocol.h"

@implementation STTTextProtocol

@synthesize text = _text;

- (STTTextProtocol*)init {
    self = [super initWithType:1];
    if (self) {
        _text  = nil;
    }
    return self;
}

- (NSData*)getContentData {
    if (_text) {
        return [self.text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return NULL;
}

- (void)setContentData:(NSData*)data {
    self.text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
