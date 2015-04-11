/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: Log日记函数
 */

#ifndef __STLOG_H__
#define __STLOG_H__

#import <Foundation/Foundation.h>

void STLog(NSString* format, ...);

#define NSLog (#warning "You shouldn't use NSLog, using STLog instead!")

#endif