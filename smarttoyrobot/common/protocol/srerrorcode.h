//
//  srerrorcode.h
//  smarttoyrobot
//
//  Created by 张唯 on 15-4-28.
//  Copyright (c) 2015年 smarttoy. All rights reserved.
//

#ifndef smarttoyrobot_srerrorcode_h
#define smarttoyrobot_srerrorcode_h

typedef enum  {
    EC_SUCESS,		// 可以代表操作成功
    // 跳舞
    EC_DANCE_START_FAILED,
    EC_DANCE_STOP_FAILED,
    // 播放音乐
    EC_PLAY_MUSIC_FAILED,
    EC_STOP_MUSIC_FAILED
}SRErrorCode;

#endif
