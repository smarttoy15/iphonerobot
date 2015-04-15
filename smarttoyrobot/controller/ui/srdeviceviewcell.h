//
//  deveiceviewcell.h
//  smarttoyrobot
//
//  Created by 张唯 on 15-4-14.
//  Copyright (c) 2015年 smarttoy. All rights reserved.
//

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-15
 Descript: 列表单元
 
 Modified:
 */

#import <UIKit/UIKit.h>
#import "srdevice.h"

@interface SRDeviceviewcell : UITableViewCell

@property (nonatomic, weak, readwrite) SRDevice *deviceInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtSubTitle;

@end
