//
//  ViewController.m
//  WJAudioRecorder
//
//  Created by 王杰 on 2019/1/16.
//  Copyright © 2019 wangjie. All rights reserved.
//

#import "ViewController.h"
#import "WJAudioRecorderController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()<WJAudioRecorderDelegate,AVAudioPlayerDelegate>
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) AVAudioSession *session;
@property NSString *filePath;
@property NSString *time;


@property (nonatomic,strong)UIButton * voiceButton;
@end

@implementation ViewController
{
    
    NSTimer *_timer; //定时器
    NSInteger countDown;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.largeTitleDisplayMode = YES;
    self.navigationItem.title = @"123333";
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
    self.session = session;
    

    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:button];
    button.backgroundColor = UIColor.redColor;
    [button setTitle:@"弹出" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    
    self.voiceButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 300, self.view.frame.size.width - 40, 40)];
    [self.view addSubview:self.voiceButton];
    self.voiceButton.backgroundColor = UIColor.lightGrayColor;
    [self.voiceButton setTitle:@"play" forState:UIControlStateNormal];
    [self.voiceButton addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)playBtnClick:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        [self.voiceButton setTitle:@"pause" forState:UIControlStateNormal];

        [self playVoice:self.filePath];
    }else{
        [self.voiceButton setTitle:self.time forState:UIControlStateNormal];
        [self.player pause];
        [self removeTimer];
    }
}

- (void)popView{
    WJAudioRecorderController * vc = [[WJAudioRecorderController alloc]init];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (void)passValue:(NSString *)filePath time:(NSInteger)time{
    
    NSLog(@"--- filePath ---:%@",filePath);
    self.filePath = filePath;
    self.time = [NSString stringWithFormat:@"%ld",time];
    [self.voiceButton setTitle:self.time forState:UIControlStateNormal];

}


#pragma mark - 播放方法
- (void)playVoice:(NSString * )url{
    
    NSLog(@"播放本地录音%@",url);
    if ([self.player isPlaying])return;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:url] error:nil];
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.filePath] options:nil];
     CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    
    NSLog(@"----获取录音时长----%f",audioDurationSeconds);
    
    // NSLog(@"%li",self.player.data.length/1024);
    // 设置代理
    self.player.delegate = self;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.player play];
    [self addTimer];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        NSLog(@"播放结束了");
        [self.voiceButton setTitle:@"play" forState:UIControlStateNormal];
        self.voiceButton.selected = NO;
        [self removeTimer];
    }else{
        NSLog(@"播放没有结束");
    }
}


/**
 *  添加定时器
 */
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshLabelText) userInfo:nil repeats:YES];
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
    countDown ++;
    
    [self.voiceButton setTitle:[NSString stringWithFormat:@"%ld/%@",countDown,self.time] forState:UIControlStateNormal];
    
    
}


@end
