//
//  studprecieve_i.h
//  smarttoysdk
//
//  Created by newma on 3/17/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: STUDPSocket的回调STTCPSocketHandler
 */

#ifndef __STUDPRECIEVE_I_H__
#define __STUDPRECIEVE_I_H__

@protocol STUDPSocketHandler <NSObject>

/**********************************************************
 @descript：当UDP接收到数据时的回调
 @argument：(NSData*)data：接收到的数据
 @argument：(NSString*)ip：数据发送来源的IP地址
 @argument：(int)port：数据发送来源的端口号
 **********************************************************/
- (void)onDataRecieve:(NSData*)data withRemoteIp:(NSString*)ip withRemotePort:(int)port;

@end

#endif
