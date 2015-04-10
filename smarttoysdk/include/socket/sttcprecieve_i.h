//
//  TCPInputCallback.h
//  test_proj
//
//  Created by newma on 2/10/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: Socket在读取数据时的回调函数
 */

#ifndef STTCPRECIEVER_I_H
#define STTCPRECIEVER_I_H

@class STTCPSocket;
@protocol STTCPRecieverInterface <NSObject>

/**********************************************************
 @descript：通知有数据可接收
 @argument：(STTCPSocket*)socket：当前处理连接的socket。
 @argument：(NSInputStream*)stream：用于读取数据的stream.
 **********************************************************/
- (void) onRecieve:(STTCPSocket*)socket withStream:(NSInputStream*)stream;

/**********************************************************
 @descript：当socket断开时，触发此函数
 @argument：(STTCPSocket*)socket：当前处理连接的socket。
 **********************************************************/
- (void) onRecieveEnd:(STTCPSocket*)socket;

/**********************************************************
 @descript：当socket出错，或者读取stream发生异常时解发此函数
 @argument：(STTCPSocket*)socket：当前处理连接的socket。
 @argument：(NSString*)errCode：错误描述
 **********************************************************/
- (void) onRecieveError:(STTCPSocket*)socket withError:(NSString*)errCode;

@end

#endif //STTCPRECIEVER_I_H
