//
//  SRVedioProtocol.m
//  smarttoyrobot
//
//  Created by 张唯 on 15-4-28.
//  Copyright (c) 2015年 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "srvedioprotocol.h"
#import "srcommand.h"

@interface SRVedioProtocol() {
    NSData *m_vedioData;
}

@end

@implementation SRVedioProtocol

- (SRVedioProtocol*)init {
    self = [super initWithType:SRC_VEDIO_DATA];
    return self;
}

- (void) setContentData:(NSData *)data {
    m_vedioData = [[NSData alloc] initWithData:data];
}

- (NSData*) getContentData {
    return m_vedioData;
}

@end
