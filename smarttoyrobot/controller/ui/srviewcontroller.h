/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 机器人控制界面
 
 Modified:
 */

#import "ViewController.h"
#import "srcontrolslider.h"

@interface SRViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *vedioView;
@property (strong, nonatomic) IBOutlet UIButton *buttonMute;
@property (strong, nonatomic) IBOutlet UIButton *buttonSpeak;
@property (strong, nonatomic) IBOutlet UIButton *buttonCameraChange;
@property (strong, nonatomic) IBOutlet UIButton *buttonDance;
@property (strong, nonatomic) IBOutlet UIButton *buttonSendEmoji;
@property (strong, nonatomic) IBOutlet UIButton *buttonMusic;


@property SRContorlSlider *leftSlider;
@property SRContorlSlider *rightSlider;


@property NSString* serverIP;

#ifdef DEBUG
@property (strong, nonatomic) IBOutlet UILabel *statusInfo;
- (void)appendMessage:(NSString*)message;
#endif

@end
