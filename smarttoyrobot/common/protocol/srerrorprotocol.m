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
    SRErrorCode m_errorCode;
}
@end

@implementation SRErrorProtocol

- (SRErrorProtocol*) initWithType:(int)type errorCode:(SRErrorCode)error{
    self = [super initWithType:type];
    m_errorCode = error;
    return self;
}

- (SRErrorCode) getErrorCode {
    return m_errorCode;
}

- (void) setErrorCode:(SRErrorCode)error {
    m_errorCode = error;
}

- (NSData*)getContentData {
    BTL_ENDIAN(m_errorCode, UInt32);
    return [NSData dataWithBytes:&m_errorCode
                          length:sizeof(m_errorCode)];
}

- (void) setContentData:(NSData *)data {
    [data getBytes:&m_errorCode
            length:sizeof(m_errorCode)];
    LTB_ENDIAN(m_errorCode, UInt32);
}


@end
