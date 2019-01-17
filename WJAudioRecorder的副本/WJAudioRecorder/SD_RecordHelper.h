//
//  SD_RecordHelper.h
//  SDRecord
//
//  Created by Stephen on 2017/12/22.
//  Copyright © 2017年 Stephen. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ///正在录音
    SD_RHRecording,
    ///录音完成
    SD_RHDone,
    ///录音暂停
    SD_RHPause,
} SD_RHRecordStatus;



typedef enum:NSUInteger{
    ///正在播放
    SD_RHPlaying,
    ///播放完成
    SD_RHPlayDone,
} SD_RHPlayStatus;


typedef void(^SD_RecordTimeBlock)(NSInteger );
typedef void(^SD_RecordDoneBlock)(NSString *);

@interface SD_RecordHelper : NSObject
///录音时间技术block
@property (copy, nonatomic) SD_RecordTimeBlock SDRecordTimeBlock;
///录音保存成功block
@property (copy, nonatomic) SD_RecordDoneBlock SDRecordDoneBlock;

///录音时长
@property (assign , nonatomic) NSInteger recordTimeIndex;

///当前录音状态
@property (assign , nonatomic) SD_RHRecordStatus recordStatus;
///当前播放状态状态
@property (assign , nonatomic) SD_RHPlayStatus playStatus;
///获取录音helper单例
+ (instancetype)share;

///开始录音
- (void)startRecord;
//停止录音
- (void)finishRecord;

///播放录音
- (void)playRecord:(NSString *)path;

/// 开始播放
- (void)startPlay;
/// 结束播放
- (void)stopPlay;


@end
