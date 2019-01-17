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
#import "SD_RecordHelper.h"

@interface WJAudioRecorderController ()

@property (nonatomic,strong)UIButton * recorderButton;
@property (nonatomic,copy)NSString * filePath;
@end

@implementation WJAudioRecorderController
{
    ///显示tape image index   录音点显示
    NSInteger _tapeImgIndex;
    
    ///录音时长  当前设置为15
    NSInteger _recordTimeIndex;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    
    recordHelper.SDRecordTimeBlock = ^(NSInteger timeCount) {
        [self setUpRecordViewStatus];
        self->_recordTimeIndex = timeCount;
        //[weakSelf recordAnimationAction];
    };
    
    recordHelper.SDRecordDoneBlock = ^(NSString * filePath){
        self.filePath = filePath;
        NSLog(@"---filePath---%@",self.filePath);
        [self setUpRecordViewStatus];

        // [self disMiss];
        
    };
    

    // 创建录制音频界面
    [self createRecorderUI];
}

- (void)createRecorderUI{
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(100, 250, 100, 100)];
    [self.view addSubview:button];
    [button setTitle:@"dismiss" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(disMiss) forControlEvents:UIControlEventTouchUpInside];
    
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
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];

    if (sender.selected) {
        [recordHelper startRecord];
    }else{ // 结束录音
        [recordHelper finishRecord];
    }
}

- (void)disMiss{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(passValue:time:)]) {
            [self.delegate passValue:self.filePath time:3];
        }
    }];
    
}


- (void)setUpRecordViewStatus{
    SD_RecordHelper *recordHelper = [SD_RecordHelper share];
    switch (recordHelper.recordStatus) {
        case SD_RHRecording:
            NSLog(@"wangjie正在录制...");
            [self.recorderButton setTitle:[NSString stringWithFormat:@"%ld",_recordTimeIndex] forState:UIControlStateNormal];

            break;
        case SD_RHPause:
            NSLog(@"wangjie暂停录制");
            
            break;
        case SD_RHDone:{
            NSLog(@"wangjie完成录制");
            [self disMiss];
            
        }
           
            break;
            
        default:
            break;
    }
    
    
}


@end
