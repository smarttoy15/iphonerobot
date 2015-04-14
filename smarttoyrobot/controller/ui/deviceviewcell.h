//
//  deveiceviewcell.h
//  smarttoyrobot
//
//  Created by 张唯 on 15-4-14.
//  Copyright (c) 2015年 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sttdevice.h"

@interface STTDeviceviewcell : UITableViewCell

@property (nonatomic, weak, readwrite) STTDevice *deviceInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTitle;

@end
