/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript:
 
 Modified:
 */

#import "srviewcontroller.h"

@interface SRViewContorller ()

@end


@implementation SRViewContorller

@synthesize SRRightSlider = _SRRightSlider;
@synthesize SRLeftSlider = _SRLeftSlider;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.SRLeftSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(0, 400, 300, 20)];
    self.SRRightSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(750, 400, 300, 20)];
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
}

- (IBAction)actionDance:(id)sender {
}

- (IBAction)actionSpeak:(id)sender {
}

- (IBAction)actionSendEmoji:(id)sender {
}

- (IBAction)actionMusic:(id)sender {
}

- (IBAction)actionLEDSwitch:(id)sender {
}

- (IBAction)actionSwitchCamera:(id)sender {
}

@end
