
//
//  STTDeviceDiscover.m
//  smarttoysdktest
//
//  Created by newma on 4/3/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "mainviewcontroller.h"
#import "network/stnetwork.h"
#import "misc/stlog.h"
#import "deviceviewcell.h"

#define DISCOVERY_PORT 8002
#define CELL_HEIGHT 100
#define REUSE_CELL_IDEN @"device cell"

@interface mainViewController () {
    NSMutableArray* m_robotList;         // 搜索到的设备列表
}

@end

@implementation mainViewController

@synthesize device = _device;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* strIP = [STNetwork getLocalIPv4FromWifi];
    if (!self.device) {
        self.device = [[STTDevice alloc]init];
        self.device.localIp = strIP;
        self.device.servicePort = DISCOVERY_PORT;
        self.device.delegate = self;
        
        self.device.title = strIP;
        self.device.subTitle = [NSString stringWithFormat:@"%d", DISCOVERY_PORT];
    }
    if (!m_robotList) {
        m_robotList = [[NSMutableArray alloc]init];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.device setup];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.device tearDown];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STTDeviceviewcell* cell = [tableView dequeueReusableCellWithIdentifier:REUSE_CELL_IDEN forIndexPath:indexPath];
    
    STTDevice* device = [m_robotList objectAtIndex:indexPath.row];
    [cell setDeviceInfo:device];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    return cell.frame.size.height;
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_robotList count];
}


- (void)onRemotePeerAdd:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    STPeer* peer = [local getPeerFromIp:remoteIp];
    if (peer) {
        [m_robotList addObject:peer];
    } else {
        STLog(@"error: peer of \"%@\" info no founded!", remoteIp);
    }
    [self.tableView reloadData];
}

- (void)onRemotePeerRemove:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    int index = 0;
    for (STPeer* peer in m_robotList) {
        if (peer.localIp == remoteIp) {
            break;
        }
        index++;
    }
    
    if (index < [m_robotList count]) {
        [m_robotList removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

- (void)onRemotePeerSearch:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    // ignore
}

- (IBAction)onSearch:(id)sender {
    [m_robotList removeAllObjects];
    [self.device searchPeer];
    [self.tableView reloadData];
}

@end
