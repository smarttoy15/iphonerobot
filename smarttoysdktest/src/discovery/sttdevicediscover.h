//
//  STTDeviceDiscover.h
//  smarttoysdktest
//
//  Created by newma on 4/3/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sttdevice.h"

@interface STTDeviceDiscover : UITableViewController <STPeerEventHandler>

@property (nonatomic, strong) STTDevice* device;

@end
