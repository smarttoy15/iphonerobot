/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 机器人控制界面
 
 Modified:
 */

#import "ViewController.h"
#import "srcontrolslider.h"

@interface SRViewContorller : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *SRVedioView;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonMute;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonSpeak;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonCameraChange;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonDance;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonSendEmoji;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonMusic;
@property (strong, nonatomic) IBOutlet UIButton *SRButtonBack;

@property SRContorlSlider *SRLeftSlider;
@property SRContorlSlider *SRRightSlider;

@end
