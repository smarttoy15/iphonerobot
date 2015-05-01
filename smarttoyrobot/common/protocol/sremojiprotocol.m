/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 机器人发送表情相关协议
 
 Modified:
 */

#import <Foundation/Foundation.h>
#import "sremojiprotocol.h"
#import "sremoji.h"
#import "misc/stutils.h"

@interface SREmojiProtocol () {
    SREMOJI m_curEmotion;
}

@end

@implementation SREmojiProtocol

- (SREmojiProtocol*) initWithType:(int)type emotion:(SREMOJI)emotion {
    self = [super initWithType:type];
    m_curEmotion = emotion;
    return self;
}

- (SREmojiProtocol*) initWithType:(int)type {
    self = [self initWithType: type
                      emotion: 1];
    return self;
}

- (void) setEmoji:(SREMOJI)emoji {
    m_curEmotion = emoji;
}

- (SREMOJI) getEmotion {
    return m_curEmotion;
}

- (NSData*) getContentData {
    int tmpInt = m_curEmotion;
    BTL_ENDIAN(tmpInt, UInt32);
    
    return [[NSData alloc ]initWithBytes:&tmpInt
                          length:sizeof(m_curEmotion)];
}

- (void) setContentData:(NSData *)data {
    [data getBytes:&m_curEmotion
            length:sizeof(m_curEmotion)];
    
    LTB_ENDIAN(m_curEmotion, UInt32);
}

@end
