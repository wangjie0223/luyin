//
//  WJAudioRecorder.m
//  WJAudioRecorder
//
//  Created by 王杰 on 2019/1/16.
//  Copyright © 2019 wangjie. All rights reserved.
//
#define kScreen_height [[UIScreen mainScreen] bounds].size.height
#define kScreen_width [[UIScreen mainScreen] bounds].size.width
#import "WJAudioRecorderController.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
@interface WJAudioRecorderController ()<AVAudioRecorderDelegate>

@property AVAudioRecorder *recorder;

/**
 文件路径
 */
@property NSString *filePath;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic,strong)UIButton * recorderButton;
@end

@implementation WJAudioRecorderController
{
    NSTimer *_timer; //定时器
    NSInteger countDown;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 250, 100, 100)];
    [self.view addSubview:button];
    [button setTitle:@"dismiss" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建录制音频界面
    [self createRecorderUI];
    
    
    //设置参数
    NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];

    // Initiate and prepare the recorder
    
    // 创建文件名 wav格式,后端转格式mp3 本地文件名
//    NSString * audioStr = [[UUID lowerUUID] stringByAppendingString:@"RRecord.wav"];
    NSString * audioStr = @"RRecord.wav";

    NSString * resultStr = [@"/" stringByAppendingString:audioStr];
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    //[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionMixWithOthers
                   error:nil];
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    //self.session = session;
    
    
    // 一定要存在文件夹里
    NSString * folder = [self createDir];
    self.filePath = [folder stringByAppendingString:resultStr];
    NSLog(@"录音音频文件路径字符串%@",self.filePath);
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_filePath] settings:recordSettings error:nil];
    // _audioRecorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
}


#pragma mark - 创建文件夹
- (NSString *)createDir {
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * folderPath;
    folderPath = [docsdir stringByAppendingPathComponent:@"voice"]; // 在Caches目录下创建 "voice" 文件夹
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:self.filePath isDirectory:&isDir];
    
    if (!(isDir && existed)) {
        // 在Document目录下创建一个archiver目录
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}




- (void)createRecorderUI{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreen_height - 200, kScreen_width, 200)];
    backView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:backView];
    // 录音按钮
    self.recorderButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(backView.frame) - 150, 20, 300, 40)];
    [backView addSubview:self.recorderButton];
    [self.recorderButton setTitle:@"点击录制" forState:UIControlStateNormal];
    self.recorderButton.backgroundColor = UIColor.redColor;
    [self.recorderButton addTarget:self action:@selector(recorderBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

// 点击开始录音
- (void)recorderBtnClick:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        if (_recorder) {
            _recorder.meteringEnabled = YES;
            [_recorder prepareToRecord];
            // [_recorder recordForDuration:600];
        
            [_recorder recordAtTime:_recorder.deviceCurrentTime + 5 forDuration:600];
            
            [self addTimer];
        }else{
            NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
        }
        

    }else{ // 结束录音
        NSLog(@"停止录音");
        if ([_recorder isRecording]) {
             [_session setCategory:AVAudioSessionCategoryPlayback error:nil];//此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
            [_recorder stop];
        }
        [self removeTimer];
        if ([self.delegate respondsToSelector:@selector(passValue:time:)]) {
            [self.delegate passValue:self.filePath time:self->countDown];
        }
        [self disMiss];

    }
    
    
}

- (void)disMiss{
    [self dismissViewControllerAnimated:YES completion:^{
//        if ([self.delegate respondsToSelector:@selector(passValue:time:)]) {
//            [self.delegate passValue:self.filePath time:self->countDown];
//        }
        
    }];
    
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    if (flag) {
        NSLog(@"录制结束.录制成功");
        
        
        
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];

    }
    
}


/**
 *  添加定时器
 */
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除定时器
 */
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
    
}



-(void)refreshLabelText{
    countDown = -3;
    countDown ++;
    
//    [self.recorderButton setTitle:[NSString stringWithFormat:@"%ld",countDown] forState:UIControlStateNormal];
    // _noticeLabel.text = [NSString stringWithFormat:@"还剩 %ld 秒",(long)countDown];
    
    [self.recorderButton setTitle:[self timeStringForTimeInterval:_recorder.currentTime] forState:UIControlStateNormal];

}


-(NSString*)timeStringForTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];

//    if (hours > 0)
//    {
//        return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
//    }
//    else
//    {
//        return  [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
//    }
}


/**获取当前系统时间的时间戳*/
- (NSInteger)getNowTimestamp{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间
    //    NSLog(@"设备当前的时间:%@",[formatter stringFromDate:datenow]);
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    //    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    return timeSp;
    
}



@end
