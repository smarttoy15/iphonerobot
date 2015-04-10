//
//  ViewController.m
//  TestHspApp
//
//  Created by newma on 14/12/9.
//  Copyright (c) 2014年 smarttoy. All rights reserved.
//

#import "ViewController.h"

#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechConstant.h"

#import <AVFoundation/AVAudioSession.h>

//#import "PcmPlayer.h"

//#import "AQPlayer.h"

void onAlertSoundFinish(SystemSoundID ssId, void* data) {
    ViewController* controller = (__bridge ViewController*)data;

    bool ret = [controller.iFlySpeechUnderstander startListening];
    if (!ret) {
        NSLog(@"打开语音误别失败");
     }
}

@interface ViewController ()
{
    SystemSoundID m_soundId;
}
@end

@implementation ViewController

- (void)setBluetoothAudioSession:(BOOL)isAllowBluetooth {
    NSError *myError = nil;
    BOOL success = false;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    success = [audioSession setActive:NO error: &myError];
    if (!success) {
        NSLog(@"[View Controller]setAudioSession: set no active failed! Error message : %@", myError.localizedDescription);
    }
    
    if (isAllowBluetooth) {
        success = [audioSession setCategory: AVAudioSessionCategoryPlayAndRecord
                                 withOptions: AVAudioSessionCategoryOptionAllowBluetooth
                                       error: &myError];
        NSLog(@"[View Controller]setAudioSession: allow bluetooth device+++++++++++++++");
    } else {
        success = [audioSession setCategory: AVAudioSessionCategoryPlayback
                                      error: &myError];
        NSLog(@"[View Controller]setAudioSession: disallow bluetooth device-------------");
    }
    
    if (!success) {
        NSLog(@"[View Controller]setAudioSession: set category failed! Error message: %@", myError.localizedDescription);
    }
    
    success = [audioSession setActive:YES error: &myError];
    if (!success) {
        NSLog(@"[View Controller]setAudioSession: set yes active! Error message : %@", myError.localizedDescription);
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
    
    NSURL *voicePath=[[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"record_sign" ofType:@"wav"]];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)voicePath , &m_soundId);
    AudioServicesAddSystemSoundCompletion(m_soundId, NULL, NULL, onAlertSoundFinish, (__bridge void*)self);
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    
    // Turn off remote control event delivery
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];

    [super viewWillDisappear:animated];
    
    AudioServicesRemoveSystemSoundCompletion(m_soundId);
    AudioServicesDisposeSystemSoundID(m_soundId);
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        if ([_iFlySpeechUnderstander isUnderstanding]) {
            [self stopUnderstand];
        }
        
        if ([_iFlySpeechSynthesizer isSpeaking]) {
            [self stopSpeak];
        }
        
        [m_player stop];
        [self onAudioPlayEnd:m_player successfully:NO];
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"[View Controller]: remoteControlReceivedWithEvent: toggle play or pause");
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"[View Controller]: remoteControlReceivedWithEvent: Previous Track");
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"[View Controller]: remoteControlReceivedWithEvent: Next Track");
                break;
                
            default:
                break;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    _iFlySpeechUnderstander.delegate = self;
    
    m_isRecognizing = false;
    
    //单例模式
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    _iFlySpeechSynthesizer.delegate = self;
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];

    [self setBluetoothAudioSession:YES];
    
    m_isNeedPlay = NO;
    m_player = [[PcmPlayer alloc] init];
    m_player.delegate = self;
}

- (void)viewDidUnload {
    
}

- (void) startUnderstand {
    AudioServicesPlayAlertSound(m_soundId);
}

- (void) stopUnderstand {
    [_iFlySpeechUnderstander stopListening];
    if (_iFlySpeechUnderstander.isUnderstanding) {
        [_iFlySpeechUnderstander cancel];
    }
}

- (Boolean)startSpeak:(NSString*) words customize:(BOOL)flag {
    [self stopSpeak];
    
    
    //TODO:
    //[self setBluetoothAudioSession:NO];
    m_isNeedPlay = flag;
    if (!flag) {
        [_iFlySpeechSynthesizer startSpeaking:words];
    } else {
        [_iFlySpeechSynthesizer synthesize:words toUri:nil];
    }
    
    return true;
}

- (void)stopSpeak {
    m_isNeedPlay = NO;
    if ([_iFlySpeechSynthesizer isSpeaking]) {
        [_iFlySpeechSynthesizer stopSpeaking];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onButtonClicked:(id)sender {
    m_isRecognizing = !m_isRecognizing;
    if (m_isRecognizing) {
        [self startUnderstand];
        [self.m_btnTriggle setTitle:@"关闭语音识别" forState: UIControlStateNormal];
//        [self.m_btnTriggle setTitle:@"关闭语音识别" forState: UIControlStateNormal];
//        [self startSpeak:@"本文档是开发科大讯飞 iOS 语音控件 SDK 的用户指南,定义了语音听写、语音合成、语义理解 以及个性化相关接口的使用说明和体系结构,所有接口必需在联网状态下才能正常使用。" customize:NO];
    } else {
        [self.m_btnTriggle setTitle:@"打开语音识别" forState: UIControlStateNormal];
        
        [m_player stop];
        [self stopSpeak];
        [self stopUnderstand];
    }
}


#pragma mark - IFlySpeechRecognizerDelegate
/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume
{
    NSLog(@"【View Controler】onVolumeChanged: voice volume %d", volume);
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech
{
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech
{

}


/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"{{{{{{{{on listen Error code: %d, msg: %@}}}}}}}}}}", error.errorCode, error.errorDesc);
    if (![_iFlySpeechSynthesizer isSpeaking]) {
        [self startSpeak:error.errorDesc customize:YES];
    }
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = results [0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    if (![result isEqual:@""]) {
        NSLog(@"!!!!!!!!!!!!!start to speak: %@", result);
        [self.m_txtAnswear setText:result];
        
        // TODO:
        if ([result length] > 1) {
            [self startSpeak:result customize:YES];
        } else {
            [self startSpeak:result customize:NO];
        }
    }
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param
 * @see
 */
- (void) onCancel
{
}

#pragma mark - IFlySpeechSynthesizerDelegate

/**
 * @fn      onSpeakBegin
 * @brief   开始播放
 *
 * @see
 */
- (void) onSpeakBegin
{
}

/**
 * @fn      onBufferProgress
 * @brief   缓冲进度
 *
 * @param   progress            -[out] 缓冲进度
 * @param   msg                 -[out] 附加信息
 * @see
 */
- (void) onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"%%%%%%%%缓冲进度为%d", progress);
}

/**
 * @fn      onSpeakProgress
 * @brief   播放进度
 *
 * @param   progress            -[out] 播放进度
 * @see
 */
- (void) onSpeakProgress:(int) progress
{
    NSLog(@"!!!!!!播放进度为%d", progress);
}

/**
 * @fn      onSpeakPaused
 * @brief   暂停播放
 *
 * @see
 */
- (void) onSpeakPaused
{
}

/**
 * @fn      onSpeakResumed
 * @brief   恢复播放
 *
 * @see
 */
- (void) onSpeakResumed
{
}

/**
 * @fn      onCompleted
 * @brief   结束回调
 *
 * @param   error               -[out] 错误对象
 * @see
 */
- (void) onCompleted:(IFlySpeechError *) error
{
    NSLog(@"【Speaker】onCompleted: TTS completely");
 
    // 中断讲话，同样会进入到此处
    if (m_isRecognizing) {
        if (m_isNeedPlay) {
            [self setBluetoothAudioSession:NO];
            
            [m_player stop];
  
            NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            dir = [dir stringByAppendingPathComponent:@"synthesizeToUri.pcm"];   //找到synthesizeToUri默认的保存文件路径 XXX/lib/caches/syntehsizeToUri.pcm
            [m_player setAudioData:dir];
            [m_player play];
        } else {
            //[self setBluetoothAudioSession:YES];
            [self startUnderstand];
        }
    }
    m_isNeedPlay = NO;
}

/**
 * @fn      onSpeakCancel
 * @brief   正在取消
 *
 * @see
 */
- (void) onSpeakCancel
{
}

#pragma mark for audio play end delegate

- (void) onAudioPlayEnd:(PcmPlayer*)pcmPlayer successfully: (BOOL)flag {
    if (m_isRecognizing)  {
        [self setBluetoothAudioSession:YES];
        [self startUnderstand];
    }
}

@end
