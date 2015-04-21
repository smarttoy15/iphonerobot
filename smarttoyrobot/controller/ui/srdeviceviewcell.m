

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: newma
 Date: 2015-4-15
 Descript: 列表单元
 
 Modified: zhangwei
 */

#import "srdeviceviewcell.h"

@implementation SRDeviceviewcell

@synthesize deviceInfo = _deviceInfo;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setDeviceInfo:(SRDevice *)deviceInfo {
    if (deviceInfo.imageUrl) {
        self.imgHead.image = [UIImage imageNamed:deviceInfo.imageUrl inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
    }
    self.txtName.text = deviceInfo.title;
    self.txtSubTitle.text = deviceInfo.subTitle;
    
    CGFloat height = self.imgHead.frame.size.height + 10.0;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

@end
