/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: Log日记函数
 */

#ifndef __STLOG_H__
#define __STLOG_H__

#import <Foundation/Foundation.h>

void __STLog(const char* file, int line, const char*function, NSString* format, ...);

#define STLog(format, arg...) __STLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, format, ##arg)

#define NSLog

#endif