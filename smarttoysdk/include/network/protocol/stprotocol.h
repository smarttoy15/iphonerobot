//
//  STProtocol.h
//  smarttoysdk
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//


/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: 协议类
 */

#ifndef __STPROTOCOL_H__
#define __STPROTOCOL_H__

@interface STBasicProtocol : NSObject

@property (nonatomic, readonly) int type;

- (STBasicProtocol*)initWithType:(int)type;

// 网络传输数据
- (NSData*)getTransferData;
- (void)setTransferData:(NSData*)data;

#pragma override method
// 内容数据
- (NSData*)getContentData;
- (void)setContentData:(NSData*)data;

@end

#endif
