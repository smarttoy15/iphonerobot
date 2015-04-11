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

/**********************************************************
 @descript：in_addr长整型转化为字符串的ipv4地址
 @argument：(const struct in_addr_t)addr：in_addr长整型的ip地址
 @return：为转化后的字符串，失败时返回nil
 **********************************************************/
+ (NSString*)getIPv4StringFromIn_Addr:(const in_addr_t)addr;

@end

#endif