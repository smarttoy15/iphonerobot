/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-4-15
 Descript: 设备发现界面
 
 Modified: zhangwei
 */

#import "srdiscovercontroller.h"
#import "network/stnetwork.h"
#import "misc/stlog.h"
#import "srdeviceviewcell.h"
#import "srviewcontroller.h"

#define DISCOVERY_PORT 8002
#define REUSE_CELL_IDEN @"device cell"

@interface SRDiscoverViewController () {
    NSMutableArray* m_robotList;         // 搜索到的设备列表
}

@end

@implementation SRDiscoverViewController

@synthesize device = _device;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    NSString* strIP = [STNetwork getLocalIPv4FromWifi];
    if (!self.device) {
        self.device = [[SRDevice alloc]init];
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
    
    SRDeviceviewcell* cell = [tableView dequeueReusableCellWithIdentifier:REUSE_CELL_IDEN forIndexPath:indexPath];
    
    SRDevice* device = [m_robotList objectAtIndex:indexPath.row];
    [cell setDeviceInfo:device];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [m_robotList count];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqual:@"maincontroller"]) {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        SRDevice* device = [m_robotList objectAtIndex:indexPath.row];
        SRViewController* controller = segue.destinationViewController;
        controller.SRServerIP = device.localIp;
    }
}


/*设备发现相关代码*/

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
