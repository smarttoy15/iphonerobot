/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript:
 当前完成功能：
    1.机器人移动通信协议
    2.机器人跳舞通信协议
    3.机器人转换摄像头协议
    4.机器人发送表情协议
    5.机器人播放音乐协议
 未完成：
    1.按住说话
    2.接受视频流
    3.静音
 Modified:
 */

#define TCP_TRANS_PORT 6534
#define SR_CHECK_TIME_INTERVAL 1.0

#import "srviewcontroller.h"
#import "socket/sttcpsocket.h"
#import "srtcpreciever.h"
#import "srtcpclienthandler.h"
#import "misc/stlog.h"


#import "srdanceprotocol.h"
#import "sremojiprotocol.h"
#import "srmusicprotocol.h"
#import "srmoveprotocol.h"
#import "srswitchcameraprotocol.h"
#import "srcommand.h"
#import "sremoji.h"

@interface SRViewController () {

    BOOL m_isMute;
    BOOL m_isSpeaking;
    BOOL m_isChangeCamera;
    BOOL m_isDancing;
    BOOL m_isPlayMusic;
    
    STTCPSocket *m_tcpClient;
    SRTCPReciever *m_tcpReceiver;
    SRTCPClientHandler *m_tcpClientHandler;
    
    NSTimer* m_timer;
    
}

/*
 *TCP连接相关函数
 */
- (void)initTCP;
- (void)startTCP;
- (void)stopTCP;

/*
 *设置定时器每个周期检查滑杆状态
 */
- (void)startTimer;
- (void)stopTimer;

/*
 *检查滑杆状态，并转换成协议
 */
- (void)checkSliderStatus;

/*
 * 在label中显示出TCP通信中的Log
 */
- (void)appendMessage:(NSString*)message;

/*
 *按钮触发的动作
 */

- (IBAction)actionMute:(id)sender; //静音，功能未完成
- (IBAction)actionSpeak:(id)sender; //按住说话,未完成
- (IBAction)actionDance:(id)sender; //发送跳舞协议
- (IBAction)actionSendEmoji:(id)sender; //发送表情
- (IBAction)actionMusic:(id)sender; //发送播放音乐请求
- (IBAction)actionSwitchCamera:(id)sender; //发送转换摄像头请求

@end


@implementation SRViewController

@synthesize SRRightSlider = _SRRightSlider;
@synthesize SRLeftSlider = _SRLeftSlider;
@synthesize SRServerIP = _SRServerIP;


- (void)initTCP {
    m_tcpReceiver = [[SRTCPReciever alloc]initWithViewController:self];
    m_tcpClientHandler = [[SRTCPClientHandler alloc]initWithViewController:self];
    
    m_tcpClient = [[STTCPSocket alloc]init];
    m_tcpClient.delegate = m_tcpClientHandler;
    m_tcpClient.readDelegate = m_tcpReceiver;
}

- (void)startTCP {
    if (!m_tcpClient.isValid) {
        if (![m_tcpClient connect:self.SRServerIP withPort:TCP_TRANS_PORT]) {
            [self appendMessage:[NSString stringWithFormat:@"connect to server %@ failed!", self.SRServerIP]];
        }
    }
}

- (void)stopTCP {
    if (m_tcpClient.isValid) {
        [m_tcpClient close];
    }
}

- (void)startTimer {
    if (!m_timer) {
        m_timer = [NSTimer scheduledTimerWithTimeInterval:SR_CHECK_TIME_INTERVAL
                                                   target:self
                                                 selector:@selector(checkSliderStatus)
                                                 userInfo:nil
                                                  repeats:YES];
        [m_timer fire];
    }
}

- (void)stopTimer {
    if ([m_timer isValid]) {
        [m_timer invalidate];
    }
}

- (void)checkSliderStatus {
    int leftPosition = self.SRLeftSlider.value;
    int rightPosition = self.SRRightSlider.value;
    
    BOOL isMove = YES;
    SRCOMMANDTYPE m_state = SRC_NONE;
    
    if(leftPosition > 0 && rightPosition > 0) {
        m_state = SRC_FORWARD;
        
    } else if (leftPosition < 0 && rightPosition < 0) {
        m_state = SRC_BACKWARD;
        
    } else if ((leftPosition > 0 && rightPosition == 0) ||
               (leftPosition == 0 && rightPosition < 0)) {
        m_state = SRC_TURN_RIGHT;
        
    } else if ((leftPosition == 0 && rightPosition > 0) ||
               (leftPosition < 0 && rightPosition == 0)) {
        m_state = SRC_TURN_LEFT;
        
    } else if (leftPosition > 0 && rightPosition < 0) {
        m_state = SRC_CLOCK_WISE;
    } else if (leftPosition < 0 && rightPosition > 0) {
        m_state = SRC_COUNTER_CLOCK_WISE;
    } else {
        
        isMove = NO;
    }
    
    if (isMove) {
        SRMoveProtocol *pro = [[SRMoveProtocol alloc] initWithType:m_state];
        [m_tcpClient send:[pro getTransferData]];
    }
}

- (void)appendMessage:(NSString*)message {
    self.SRStatusInfo.text = [NSString stringWithFormat:@"%@\n%@", message, self.SRStatusInfo.text];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.SRLeftSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(0, 350, 300, 20)];
    self.SRRightSlider = [[SRContorlSlider alloc] initWithFrame:CGRectMake(750, 350, 300, 20)];
    [self.view addSubview:self.SRLeftSlider];
    [self.view addSubview:self.SRRightSlider];
    [self initTCP];
    [self startTCP];
    [self startTimer];
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
   
    if (m_isDancing == NO) {
        m_isDancing = YES;
        SRDanceProtocol *pro = [[SRDanceProtocol alloc] initWithType:SRC_REQUEST_DANCE];
        [m_tcpClient send:[pro getTransferData]];
    } else {
        m_isDancing = NO;
        SRDanceProtocol *pro = [[SRDanceProtocol alloc] initWithType:SRC_STOP_DANCE];
        [m_tcpClient send:[pro getTransferData]];
    }
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
    SREmojiProtocol *pro = [[SREmojiProtocol alloc] initWithType:SRC_EMOJI_INFO emotion:FACE_SMILE];
    [m_tcpClient send:[pro getTransferData]];
}

- (IBAction)actionMusic:(id)sender {
    if (m_isPlayMusic == NO) {
        m_isPlayMusic = YES;
        SRMusicProtocol *pro = [[SRMusicProtocol alloc] initWithType:SRC_REQUEST_MUSIC];
        [m_tcpClient send:[pro getTransferData]];
    } else {
        m_isPlayMusic = NO;
        SRMusicProtocol *pro = [[SRMusicProtocol alloc] initWithType:SRC_STOP_MUSIC];
        [m_tcpClient send:[pro getTransferData]];
    }
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
    SRSwitchCameraProtocol *pro = [[SRSwitchCameraProtocol alloc] initWithType:SRC_SWITCH_CAMERA];
    [m_tcpClient send:[pro getTransferData]];
}

@end
