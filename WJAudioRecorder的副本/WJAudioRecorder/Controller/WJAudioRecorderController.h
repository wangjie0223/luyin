//
//  WJAudioRecorder.h
//  WJAudioRecorder
//
//  Created by 王杰 on 2019/1/16.
//  Copyright © 2019 wangjie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol WJAudioRecorderDelegate <NSObject>

@optional
- (void)passValue:(NSString *)filePath time:(NSInteger)time;

@end

@interface WJAudioRecorderController : UIViewController
@property (nonatomic, weak)id <WJAudioRecorderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
