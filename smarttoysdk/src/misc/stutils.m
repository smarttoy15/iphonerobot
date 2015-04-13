//
//  stutils.m
//  smarttoysdk
//
//  Created by newma on 4/12/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "misc/stutils.h"

void byteSwap(UInt8* src, UInt8* dst) {
    if (*src != *dst) {
        *src = *src + *dst;
        *dst = *src - *dst;
        *src = *src - *dst;
    }
}

@implementation STUtils

+ (void)swapEndian:(UInt8*)src withLength:(int)length toDistance:(UInt8*)dst {
    assert(src && dst);
    
    if (src != dst) {
        memcpy(dst, src, length);
    }
    int loop = length / 2;
   
    for (int i = 0; i < loop; i++) {
        byteSwap(&dst[i], &dst[length - i - 1]);
    }
}

@end


