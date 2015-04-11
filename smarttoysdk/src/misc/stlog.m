//
//  stlog.m
//  smarttoysdk
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: Log日记函数
 */

#import <Foundation/Foundation.h>
#import "misc/stlog.h"

void STLog(NSString* format, ...) {
    va_list argList;
    
    va_start(argList, format);
    NSString *outStr = [[NSString alloc]initWithFormat:format arguments:argList];
    va_end(argList);
    
#ifdef DEBUG
    fprintf(stdout, "%s:%d(%s): %s", __FILE__, __LINE__, __PRETTY_FUNCTION__, outStr.UTF8String);
#else
    fprintf(stdout, "%s", outStr.UTF8String);
#endif //DEBUG
}