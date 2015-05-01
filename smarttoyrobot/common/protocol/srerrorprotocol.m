/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 错误相关协议
 
 Modified:
 */

#import <Foundation/Foundation.h>
#import "srerrorprotocol.h"
#import "srerrorcode.h"
#import "misc/stutils.h"

@interface SRErrorProtocol() {
    SRERRORCODE m_errorCode;
}
@end

@implementation SRErrorProtocol

- (SRErrorProtocol*) initWithType:(int)type errorCode:(SRERRORCODE)error{
    self = [super initWithType:type];
    m_errorCode = error;
    return self;
}

- (SRERRORCODE) getErrorCode {
    return m_errorCode;
}

- (void) setErrorCode:(SRERRORCODE)error {
    m_errorCode = error;
}

- (NSData*)getContentData {
    int tmpInt = m_errorCode;
    BTL_ENDIAN(tmpInt, UInt32);
    return [NSData dataWithBytes:&tmpInt
                          length:sizeof(tmpInt)];
}

- (void) setContentData:(NSData *)data {
    [data getBytes:&m_errorCode
            length:sizeof(m_errorCode)];
    LTB_ENDIAN(m_errorCode, UInt32);
}


@end
