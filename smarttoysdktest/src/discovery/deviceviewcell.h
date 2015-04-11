//
//  deviceviewcell.h
//  smarttoysdktest
//
//  Created by newma on 4/4/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sttdevice.h"

@interface STTDeviceViewCell : UITableViewCell

@property (nonatomic, weak, readwrite) STTDevice* deviceInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTitle;

@end
