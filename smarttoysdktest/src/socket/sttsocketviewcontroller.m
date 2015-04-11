//
//  STTSocketViewController.m
//  smarttoysdktest
//
//  Created by newma on 4/4/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttsocketviewcontroller.h"
#import "network/stnetwork.h"

#import "tcp/stttcpserverhandler.h"
#import "tcp/stttcpreciever.h"
#import "tcp/stttcpclienthandler.h"

#import "udp/sttudpreciever.h"
#import "socket/studpsocket.h"
#import "sttcommander.h"

#define TCP_TRANS_PORT 6501

#define UDP_TRANS_PORT 5009

@interface STTSocketViewController () {
    STTCPServer* m_tcpServer;
    STTCPSocket* m_tcpClient;
    STTTCPReciever* m_tcpReciever;
    STTTCPClientHandler* m_tcpClientHandler;
    STTTCPServerHandler* m_tcpServerHandler;
    
    STTUDPReciever* m_udpReciever;
    STUDPSocket* m_udpSocket;
}

- (void)initTCP;
- (BOOL)startTCP;
- (void)stopTCP;

- (void)initUDP;
- (BOOL)startUDP;
- (void)stopUDP;

@end

@implementation STTSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTCP];
    [self initUDP];
}

- (void)initTCP {
    m_tcpReciever = [[STTTCPReciever alloc]initWithViewController:self];
    m_tcpClientHandler = [[STTTCPClientHandler alloc]initWithViewController:self];
    m_tcpServerHandler = [[STTTCPServerHandler alloc]initWithViewController:self];
    
    m_tcpServer = [[STTCPServer alloc]initWithPort:TCP_TRANS_PORT];
    m_tcpServer.delegate = m_tcpServerHandler;
    m_tcpServer.readDelegate = m_tcpReciever;
    
    m_tcpClient = [[STTCPSocket alloc]init];
    m_tcpClient.delegate = m_tcpClientHandler;
    m_tcpClient.readDelegate = m_tcpReciever;
}

- (BOOL)startTCP {
    if (!m_tcpServer.isWorking) {
        if (![m_tcpServer start]) {
            [self appendMessage:@"start tcp server failed!"];
            return NO;
        }
    }
    return YES;
}
- (void)stopTCP {
    if (m_tcpClient.isValid) {
        [m_tcpClient close];
    }
    
    if (m_tcpServer.isWorking) {
        [m_tcpServer close];
    }
}

- (void)initUDP {
    m_udpReciever = [[STTUDPReciever alloc]initWithViewController:self];
    m_udpSocket = [[STUDPSocket alloc]init];
    m_udpSocket.delegate = m_udpReciever;
    m_udpSocket.localPort = UDP_TRANS_PORT;
}

- (BOOL)startUDP {
    if (![m_udpSocket isValidate]) {
        if (![m_udpSocket open]) {
            [self appendMessage:@"initialize upd failed!"];
            return NO;
        }
    }
    return YES;
}

- (void)stopUDP {
    if ([m_udpSocket isValidate]) {
        [m_udpSocket close];
    }
}

- (void)writeMessage:(NSString*)message {
    self.txtRecMessage.text = message;
}

- (void)appendMessage:(NSString*)message {
   self.txtRecMessage.text = [NSString stringWithFormat:@"%@\n%@", message, self.txtRecMessage.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    NSString* title = self.isTCP ? @"TCP Socket测试" : @"UDP Socket测试";
    self.navTitle.title = title;
    
    [self.btnConnect setHidden:!self.isTCP];
    
    NSString* localIp = [STNetwork getLocalIPv4FromWifi];
    if (localIp) {
        self.txtLocalIp.text = localIp;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isTCP) {
        [self startTCP];
    } else {
        [self startUDP];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isTCP) {
        [self stopTCP];
    } else {
        [self stopUDP];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onSendClick:(id)sender {
    
    NSData* message = [self.txtSendMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    
    if (self.isTCP) {
        message = [STTCommander getCommandTransferData:message];
        
        if (m_tcpClient.isValid) {
            if ([m_tcpClient send:message]) {
                [self appendMessage:@"send message successfully!"];
            }
        } else {
            if (m_tcpServer.isWorking) {
                [m_tcpServer sendAllSessionsMessage:message];
            }
        }
        
    } else {
        NSString* remoteIp = self.txtRemoteIp.text;
        if ([m_udpSocket send:message toIp:remoteIp toPort:UDP_TRANS_PORT]) {
            [self appendMessage:@"send message successfully!"];
        }
    }
}

- (IBAction)onConnectClick:(id)sender {
    if (!m_tcpClient.isValid) {
        NSString* remoteIp = self.txtRemoteIp.text;
        if (![m_tcpClient connect:remoteIp withPort:TCP_TRANS_PORT]) {
            [self appendMessage:[NSString stringWithFormat:@"connect to server %@ failed!", remoteIp]];
        }
    }
}

@end
