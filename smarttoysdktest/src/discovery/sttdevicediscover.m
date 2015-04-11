
//
//  STTDeviceDiscover.m
//  smarttoysdktest
//
//  Created by newma on 4/3/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import "sttdevicediscover.h"
#import "network/stnetwork.h"
#import "misc/stlog.h"
#import "deviceviewcell.h"

#define DISCOVERY_PORT 8002
#define REUSE_CELL_IDEN @"device cell"

@interface STTDeviceDiscover () {
    NSMutableArray* m_searchedIp;         // 搜索到的设备列表
}

@end

@implementation STTDeviceDiscover

@synthesize device = _device;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.tableView registerClass:[STTDeviceViewCell class] forCellReuseIdentifier:REUSE_CELL_IDEN];

    UINib* nib = [UINib nibWithNibName:@"devicecell" bundle:[NSBundle mainBundle]];
    [self.tableView
     registerNib:nib forCellReuseIdentifier:REUSE_CELL_IDEN];
    
    NSString* strIP = [STNetwork getLocalIPv4FromWifi];
    
    if (strIP) {
        //self.txtIP.text = strIP;
    }
    
    if (!self.device) {
        self.device = [[STTDevice alloc]init];
        self.device.localIp = strIP;
        self.device.servicePort = DISCOVERY_PORT;
        self.device.delegate = self;
        
        self.device.title = strIP;
        self.device.subTitle = [NSString stringWithFormat:@"%d", DISCOVERY_PORT];
    }
    if (!m_searchedIp) {
        m_searchedIp = [[NSMutableArray alloc]init];
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
    
    STTDeviceViewCell* cell = [tableView dequeueReusableCellWithIdentifier:REUSE_CELL_IDEN forIndexPath:indexPath];
    
    STTDevice* device = [m_searchedIp objectAtIndex:indexPath.row];
    cell.deviceInfo = device;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   // UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
//    return cell.frame.size.height;
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_searchedIp count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // todo: 当被点选时的要触发的行为
}

- (void)onRemotePeerAdd:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    STPeer* peer = [local getPeerFromIp:remoteIp];
    if (peer) {
        [m_searchedIp addObject:peer];
    } else {
        STLog(@"error: peer of \"%@\" info no founded!", remoteIp);
    }
    [self.tableView reloadData];
}

- (void)onRemotePeerRemove:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    int index = 0;
    for (STPeer* peer in m_searchedIp) {
        if (peer.localIp == remoteIp) {
            break;
        }
        index++;
    }
    
    if (index < [m_searchedIp count]) { // 找到了
        [m_searchedIp removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

- (void)onRemotePeerSearch:(STPeer *)local withRemotePeerIp:(NSString *)remoteIp {
    // ignore
}

- (IBAction)onSearch:(id)sender {
    [m_searchedIp removeAllObjects];
    [self.device searchPeer];
    [self.tableView reloadData];
}

@end
