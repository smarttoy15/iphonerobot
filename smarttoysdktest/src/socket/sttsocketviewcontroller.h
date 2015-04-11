//
//  STTSocketViewController.h
//  smarttoysdktest
//
//  Created by newma on 4/4/15.
//  Copyright (c) 2015 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTSocketViewController : UIViewController

@property (nonatomic, readwrite) BOOL isTCP;

@property (weak, nonatomic) IBOutlet UILabel *txtLocalIp;

@property (weak, nonatomic) IBOutlet UITextField *txtRemoteIp;
@property (weak, nonatomic) IBOutlet UITextView *txtRecMessage;
@property (weak, nonatomic) IBOutlet UITextView *txtSendMessage;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;

- (void)writeMessage:(NSString*)message;
- (void)appendMessage:(NSString*)message;
@end
