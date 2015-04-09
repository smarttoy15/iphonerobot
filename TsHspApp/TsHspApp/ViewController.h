//
//  ViewController.h
//  TestHspApp
//
//  Created by newma on 14/12/9.
//  Copyright (c) 2014年 smarttoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"

#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechUnderstander.h"
#import "PcmPlayer.h"

@interface ViewController : UIViewController<IFlySpeechSynthesizerDelegate,IFlySpeechRecognizerDelegate, AudioPlayEndDelegate>
{
    Boolean m_isRecognizing;
    BOOL m_isNeedPlay;
    PcmPlayer* m_player;
}

//语义理解对象
@property (nonatomic,strong) IFlySpeechUnderstander *iFlySpeechUnderstander;

//合成对象
@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;

@property (weak, nonatomic) IBOutlet UILabel *m_txtQuestion;
@property (weak, nonatomic) IBOutlet UILabel *m_txtAnswear;
@property (weak, nonatomic) IBOutlet UIButton *m_btnTriggle;

- (void)setBluetoothAudioSession:(BOOL)isAllowBluetooth;

- (void)startUnderstand;
- (void)stopUnderstand;
- (Boolean)startSpeak:(NSString*) words customize:(BOOL)flag;
- (void)stopSpeak;

@end

