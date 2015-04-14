/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 控制界面
 
 Modified:
 */

#import <UIKit/UIKit.h>
#import "sttdevice.h"

@interface mainViewController : UITableViewController <STPeerEventHandler>

@property (nonatomic, strong) STTDevice *device;

@end

