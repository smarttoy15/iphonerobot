//
//  SRCommand.h
//  smarttoyrobot
//
//  Created by newma on 3/21/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//
/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-20 12:07
 Descript: 协议类
 */

#ifndef __SRCOMMAND_H__
#define __SRCOMMAND_H__

typedef enum {
    SRC_NONE,
    SRC_FORWARD,
    SRC_BACKWARD,
    SRC_TURN_LEFT,
    SRC_TURN_RIGHT,
    SRC_STOP,
    SRC_MOVE_FL,
    SRC_MOVE_FR,
    SRC_MOVE_BL,
    SRC_MOVE_BR,
    SRC_CLOCK_WISE,
    SRC_COUNTER_CLOCK_WISE,
    SRC_BRING_UP,
    SRC_BRING_DOWN,
    SRC_STOP_BRING,
    SRC_CHEST_LIGHT,
    SRC_HAND_LIGHT,
    
    SRC_SWITCH_CAMERA,
    // Dance
    SRC_REQUEST_DANCE,
    SRC_STOP_DANCE,
    // Audio
    SRC_REQUEST_AUDIO,
    SRC_STOP_AUDIO,
    
    
    
    // Music
    SRC_REQUEST_MUSIC,
    SRC_STOP_MUSIC,
    
    // UDP
    SRC_VEDIO_DATA,
    SRC_AUDIO_DATA,
    SRC_CAMERA_INFO,	// server to client
    
    SRC_ERROR,			// 操作错误协议
    
    //Responds with server use
    SRC_MUSIC_RESPOND_SUCC,
    SRC_STOP_MUSIC_RESPOND_SUCC,
    SRC_MUSIC_RESPOND_FAIL,			 //Music
    
    SRC_DANCE_RESPOND_SUCC,
    SRC_STOP_DANCE_RESPOND_SUCC,
    SRC_DANCE_RESPOND_FAIL,			 //Dance
    
    SRC_AUDIO_RESPOND_SUCC,
    SRC_STOP_AUDIO_RESPOND_SUCC,
    SRC_AUDIO_RESPOND_FAIL,			 //Audio
    
    SRC_EMOJI_INFO,
    
    // just for test
    SRC_SIMPLE_TEXT,
    
} SRCOMMANDTYPE;

#endif //__SRCOMMAND_H__
