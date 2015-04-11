//
//  TCPSocket.m
//  test_proj
//
//  Created by newma on 2/9/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-3-16
 Descript: STTCPSocket的实现
 */

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "socket/sttcpsocket.h"
#import "network/stnetwork.h"
#import "misc/stlog.h"

@interface STTCPSocket() <NSStreamDelegate>
{
    bool m_isValid;
    
    NSInputStream* _input;
    NSOutputStream* _output;
}

-(CFSocketNativeHandle) getSockNativeHandlerFromNSStream: (NSStream *)stream;
@end

@implementation STTCPSocket

@synthesize remoteIp = _remoteIp;
@synthesize remotPort = _remotPort;
@synthesize delegate = _delegate;
@synthesize readDelegate = _readDelegate;
@synthesize input = _input;
@synthesize output = _output;
@synthesize socketId = _socketId;

- (BOOL)isValid {
    return m_isValid;
}

- (STTCPSocket*)initWithRemoteAddress:(NSString*)ip withPort:(int)port {
    self = [super init];
    
    _socketId = -1;
    _remoteIp = ip;
    _remotPort = port;
    
    _input = nil;
    _output = nil;
    
    _delegate = nil;
    _readDelegate = nil;
    
    m_isValid = false;
    
    return self;
}

- (BOOL)connect:(NSString*)ip withPort:(int)port {
    
    BOOL bRet = NO;
    
    if (m_isValid) {
        STLog(@"error: TCPSocket has been connected!");
        return bRet;
    }
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ip, port, &readStream, &writeStream);
    
    if (readStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        _input = (__bridge NSInputStream*)readStream;
        
        [_input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _input.delegate = self;
        [_input open];
        
        CFRelease(readStream);
        
        bRet = YES;
    }
    
    if (writeStream) {
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        _output = (__bridge NSOutputStream*)writeStream;
        [_output open];
        
        CFRelease(writeStream);
        
        bRet = YES;
    }
    
    return bRet;
}

- (BOOL)connect {
    return [self connect:_remoteIp withPort:_remotPort];
}

- (STTCPSocket*)initWithSocket:(int)cfNativeSocketHandler withId:(int)socketId {
    self = [super init];
    
    _socketId = socketId;
    
    CFReadStreamRef inputStream = NULL;
    CFWriteStreamRef outputStream = NULL;
    
    CFStreamCreatePairWithSocket(NULL, (CFSocketNativeHandle)cfNativeSocketHandler, &inputStream, &outputStream);
    
    if (inputStream) {
        _input = (__bridge NSInputStream*)inputStream;
        
        _input.delegate = self;
        [_input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_input open];
        
        CFRelease(inputStream);
    }
    
    if (outputStream) {
        _output = (__bridge NSOutputStream*)outputStream;
        
        [_output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_output open];
        
        CFRelease(outputStream);
    }

    return self;
}

- (BOOL)send:(const void*)data dataLength:(unsigned long)length {
    if (m_isValid && _output != nil) {
        
        CFSocketNativeHandle socket = [self getSockNativeHandlerFromNSStream:_output];
        
        send(socket, (const void *)data, length, 0);
        
        return YES;
    }
    return NO;
}

- (BOOL)send:(NSData*)data {
    return [self send:data.bytes dataLength:[data length]];
}

- (void)close {
    if (m_isValid && self.socketId != -1) {
        NSStream* stream = _input ? _input : _output;
        CFSocketNativeHandle socket = [self getSockNativeHandlerFromNSStream:stream];
        close(socket);
    }
    
    if (_input != nil) {
        [_input close];
        [_input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _input.delegate = nil;
        _input = nil;
    }
    
    if (_output != nil) {
        [_output close];
        [_output removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _output = nil;
    }
    
    if (m_isValid && self.delegate != nil) {
        [self.delegate onDisconnected:self];
    }
    
    m_isValid = NO;
}

- (void)dealloc {
    [self close];
}

#define MAX_BUFFER_LENGTH 65535

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {

    assert(aStream != nil);
    
    switch (eventCode) {
        case NSStreamEventHasSpaceAvailable:    // write
            // ignore
            break;
        case NSStreamEventHasBytesAvailable:    // read
        {
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                if (self.readDelegate != nil) {
                    [self.readDelegate onRecieve:self withStream:(NSInputStream*)aStream];
                }
            }
            break;
        }
        case NSStreamEventEndEncountered:
            // server closed
            STLog(@"on stream event end encountered");
            
            if (self.readDelegate != nil) {
                [self.readDelegate onRecieveEnd:self];
            }
            
            break;
        case NSStreamEventErrorOccurred:
            STLog(@"on stream event error occurred");
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                if (self.readDelegate != nil) {
                    [self.readDelegate onRecieveError:self withError:[NSError description]];
                }
            }
            
            break;
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            m_isValid = true;
            if ([aStream isKindOfClass:[NSInputStream class]]) {
                if (self.delegate != nil) {
                    [self.delegate onConnected:self];
                }
            }

            break;
        default:
            assert(false);
    }
}

-(CFSocketNativeHandle) getSockNativeHandlerFromNSStream: (NSStream *)stream
{
    int sock = -1;
    
    if (stream) {
        NSData *sockObj = [stream propertyForKey:
                       (__bridge NSString *)kCFStreamPropertySocketNativeHandle];
        if ([sockObj isKindOfClass:[NSData class]] &&
            ([sockObj length] == sizeof(int)) ) {
            const int *sockptr = (const int *)[sockObj bytes];
            sock = *sockptr;
        }
    }
    
    return sock;
}

@end
