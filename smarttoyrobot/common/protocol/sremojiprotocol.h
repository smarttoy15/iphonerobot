/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 机器人发送表情相关协议
 
 Modified:
 */

#import "network/protocol/stprotocol.h"
#import "sremoji.h"

@interface SREmojiProtocol : STBasicProtocol

- (SREmojiProtocol*) initWithType:(int)type;
- (SREmojiProtocol*) initWithType:(int)type emotion:(SREmoji)emotion;
@end
