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
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import "misc/stlog.h"

#define MAX_BACK_TRACE_COUNT 128
NSString* getBackTraceFrame(int lastFrames) {
    void* callBack[MAX_BACK_TRACE_COUNT];
    int frames = backtrace(callBack, MAX_BACK_TRACE_COUNT);
    char** strs = backtrace_symbols(callBack, frames);
    
    NSString* bRet = [NSString stringWithUTF8String:strs[lastFrames]];
    free(strs);
    return bRet;
}

const char* trimFilePath(const char* file) {
    const char* retString = strstr(file, "smarttoy");
    if (!retString) {
        retString = file;
    }
    return retString;
}

void __STLog(const char* file, int line, const char* function, NSString* format, ...) {
    va_list argList;
    
    va_start(argList, format);
    NSString *outStr = [[NSString alloc]initWithFormat:format arguments:argList];
    va_end(argList);
    
#if DEBUG
    fprintf(stdout, "%s:%d(%s): %s\n", trimFilePath(file), line, function, outStr.UTF8String);
#else
    fprintf(stdout, "%s:%d(%s): %s\n", file, line, function, outStr.UTF8String);
#endif
}