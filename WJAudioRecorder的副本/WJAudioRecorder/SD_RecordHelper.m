//
//  SD_RecordHelper.m
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//

#import "SD_RecordHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "Record.h"
// #import "RecordDataAccessor.h"


#define kRecordDuration 600

@interface SD_RecordHelper ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    
    ///录音时长
//    NSInteger _recordTimeIndex;
    ///录音地址
    NSString *_recordPath;
    
    NSString *_recordName;
    
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@property (nonatomic,strong) NSTimer *timer;//录音timer

@end

static SD_RecordHelper *_SD_RecordHelper = nil;

@implementation SD_RecordHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recordStatus = SD_RHDone;
        _recordName = @"录音文件.wav";
        [self setAudioSession];
    }
    return self;
}

+ (instancetype)share{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _SD_RecordHelper = [[super allocWithZone:NULL] init];
    });
    
    return _SD_RecordHelper;
    
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [SD_RecordHelper share];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [SD_RecordHelper share];
}

#pragma mark - 开始录音
- (void)startRecord{
    // 设置录音状态为 正在录音
    _recordStatus = SD_RHRecording;
    [self configAudioRecorder];
    [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    [self configTimer];
    NSLog(@"录音 == 开始");
}

#pragma mark - 停止录音
- (void)finishRecord{
    // 设置录音状态为 录音完成
    _recordStatus = SD_RHDone;
    [self.audioRecorder stop];
    // 结束计时器
    [_timer invalidate];
    _timer = nil;
}


- (void)configTimer{
    if (!_timer) {
        _recordTimeIndex = 0;
        _timer = [NSTimer timerWithTimeInterval:1
                                         target:self
                                       selector:@selector(startRecordAction)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

///开始录音的各种操作
- (void)startRecordAction{
    
    NSLog(@"%@", [NSString stringWithFormat:@"录音%ld秒",(long)_recordTimeIndex]);
    
    //传出时间计数
    if (self.SDRecordTimeBlock) {
        self.SDRecordTimeBlock(_recordTimeIndex);
    }
    
    if (_recordTimeIndex < kRecordDuration) {
        self.recordStatus = SD_RHRecording;
        _recordTimeIndex += 1;
    }else{
        self.recordStatus = SD_RHDone;
        // 停止录音
        [self.audioRecorder stop];
    }
}


/**
 *  设置音频会话
 */
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

///获取录音地址
-(NSURL *)getSavePath{
    _recordPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _recordPath = [_recordPath stringByAppendingPathComponent:_recordName];
    NSLog(@"录音路径:file path:%@",_recordPath);
    NSURL *url=[NSURL fileURLWithPath:_recordPath];
    return url;
}


///取得录音文件设置
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置录音格式, iOS录音的格式为PCM格式,可以转换其他的录音格式，具体的Google一下吧
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    //是否使用浮点数采样
    //[dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}


/// 配置录音机
-(void)configAudioRecorder{
    
    //录音文件保存路径，我设置的路径是当前时间的字符串，注意路径不要有空格
    NSURL *url = [self getSavePath];
    //录音格式设置
    NSDictionary *setting = [self getAudioSetting];
    //录音机
    NSError *error=nil;
    _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
    _audioRecorder.delegate=self;
    //这个设置为YES可以做音波的效果，我没有实现音波功能
    _audioRecorder.meteringEnabled=YES;
    [_audioRecorder prepareToRecord];
    if (error) {
        NSLog(@"创建录音机audioRecorder发生错误:%@",error.localizedDescription);
    }
    
}

#pragma mark - AVAudioRecorderDelegate 录音完成
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{

    ///录音完成
    if (self.SDRecordDoneBlock) {
        self.SDRecordDoneBlock(_recordPath);
    }
    NSLog(@"AVAudioRecorderDelegate录音完成!");
}

///获取播放器
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误,错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

///播放录音
- (void)playRecord:(NSString *)path{
    NSURL *url=[NSURL fileURLWithPath:path];
    NSError *error=nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops=0;
    [self.audioPlayer prepareToPlay];
    self.audioPlayer.delegate = self;
    if (error) {
        NSLog(@"创建播放器过程中发生错误,错误信息：%@",error.localizedDescription);
    }
    [self.audioPlayer play];
}


/// 开始播放
- (void)startPlay{
    _playStatus = SD_RHPlaying;
    [self configAudioPlayer];
    [self.audioPlayer play];
    [self configTimerForPlay];

}

- (void)configTimerForPlay{
    
    
    
}

/// 结束播放
- (void)stopPlay{
    _playStatus = SD_RHPlayDone;
    [self.audioPlayer stop];
}


- (void)configAudioPlayer{
    NSURL *url = [NSURL fileURLWithPath:_recordPath];
    NSError *error=nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops=0;
    [self.audioPlayer prepareToPlay];
    self.audioPlayer.delegate = self;
    if (error) {
        NSLog(@"创建播放器过程中发生错误,错误信息：%@",error.localizedDescription);
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        NSLog(@"播放完成回调");
    }else{
        NSLog(@"播放失败回调!!!");

    }
}


@end
