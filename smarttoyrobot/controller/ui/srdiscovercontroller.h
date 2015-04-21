/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 设备发现界面
 
 Modified:
 */

#import <UIKit/UIKit.h>
#import "srdevice.h"

@interface SRDiscoverViewController : UITableViewController <STPeerEventHandler>

@property (nonatomic, strong) SRDevice *device;

@end

