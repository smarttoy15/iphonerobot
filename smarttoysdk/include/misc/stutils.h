/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-4-11 18:20
 Descript: 工具类集合
 */

#ifndef smarttoysdk_stutils_h
#define smarttoysdk_stutils_h

#import <Foundation/Foundation.h>
@interface STUtils : NSObject

+ (void)swapEndian:(UInt8*)src withLength:(int)length toDistance:(UInt8*)dst;

@end

#define BTL_ENDIAN(value, type) \
{ \
    if (value != 0) \
        [STUtils swapEndian:(UInt8*)&value withLength:sizeof(type) toDistance:(UInt8*)&value]; \
}

#define LTB_ENDIAN BTL_ENDIAN

#endif
