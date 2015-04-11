//
//  staudioconfigure.h
//  smarttoysdk
//
//  Created by newma on 3/25/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-25 17:29
 Descript: Log日记函数
 */

#ifndef smarttoysdk_staudioconfigure_h
#define smarttoysdk_staudioconfigure_h

typedef enum {
    emMono = 1,
    emStereo = 2
} STAUDIOCHANNAL;

typedef enum {
    em8Bit = 8,
    em16Bit = 16
} STAUDIOBIT;

typedef struct {
    STAUDIOCHANNAL channal;     // 声道
    unsigned long sampleRate;       // 采样频率
    STAUDIOBIT bit;             // 样本大小
} STAudioConfigure;

#endif
