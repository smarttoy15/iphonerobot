/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript:
 
 Modified:
 */
#define TCP_TRANS_PORT 6534

#import "srviewcontroller.h"
#import "misc/stlog.h"

@interface SRViewController () {

    bool m_isMute;
    bool m_isSpeaking;
    bool m_isChangeCamera;
    
}

@end


@implementation SRViewController

@synthesize SRRightSlider = _SRRightSlider;
@synthesize SRLeftSlider = _SRLeftSlider;
@synthesize SRServerIP = _SRServerIP;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.SRLeftSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(0, 350, 300, 20)];
    self.SRRightSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(750, 350, 300, 20)];
    [self.view addSubview:self.SRLeftSlider];
    [self.view addSubview:self.SRRightSlider];    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// button press action
- (IBAction)actionMute:(id)sender {
    if ( m_isMute == NO) {
        [self.SRButtonMute setBackgroundImage:[UIImage imageNamed:@"sr_mute_pressed.png"]
                                   forState:UIControlStateNormal];
        m_isMute = YES;
    } else {
        [self.SRButtonMute setBackgroundImage:[UIImage imageNamed:@"sr_mute.png"]
                                   forState:UIControlStateNormal];
        m_isMute = NO;
    }
}

- (IBAction)actionDance:(id)sender {
}

- (IBAction)actionSpeak:(id)sender {
    
    if (m_isSpeaking == NO) {
        [self.SRButtonSpeak setBackgroundImage:[UIImage imageNamed:@"sr_speak_pressed.png"]
                                    forState:UIControlStateNormal];
        m_isSpeaking = YES;
    } else {
        [self.SRButtonSpeak setBackgroundImage:[UIImage imageNamed:@"sr_speak.png"]
                                    forState:UIControlStateNormal];
        m_isSpeaking = NO;
    }
}

- (IBAction)actionSendEmoji:(id)sender {
}

- (IBAction)actionMusic:(id)sender {
}

- (IBAction)actionSwitchCamera:(id)sender {
    
    if (m_isChangeCamera == NO) {
        [self.SRButtonCameraChange setBackgroundImage:[UIImage imageNamed:@"sr_switch_camera_pressed.png"]
                                           forState:UIControlStateNormal];
        m_isChangeCamera = YES;
    } else {
        [self.SRButtonCameraChange setBackgroundImage:[UIImage imageNamed:@"sr_switch_camera.png"]
                                           forState:UIControlStateNormal];

        m_isChangeCamera = NO;
    }
}

- (IBAction)actionBack:(id)sender {
}

@end
