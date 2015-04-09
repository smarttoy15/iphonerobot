//
//  SRDevice.h
//  smarttoyrobot
//
//  Created by newma on 3/18/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-18 15:07
 Descript: 设备发现类，用于局域网中搜索相同的设备
 */

#ifndef __SRDEVICE_H__
#define __SRDEVICE_H__

#import "network/stpeer.h"

@interface SRDevice : STPeer

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* subTitle;
@property (nonatomic, strong) NSString* imageUrl;

- (NSData*)getContentData;
- (void)parseContentData:(NSData*)data;

@end

#endif
