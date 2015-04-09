/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-17 15:07
 Descript: Socket在读取数据时的回调函数
 */

#ifndef __STNETWORK_H__
#define __STNETWORK_H__

#import <Foundation/Foundation.h>

@interface STNetwork : NSObject

/**********************************************************
 @descript：通过wifi获取本地的ipv4地址
 **********************************************************/
+ (NSString*)getLocalIPv4FromWifi;

@end

#endif