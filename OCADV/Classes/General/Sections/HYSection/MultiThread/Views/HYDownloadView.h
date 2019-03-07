//
//  HYDownloadView.h
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYDownloadFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYDownloadView : UIView

// 数据模型
@property (nonatomic, strong) HYDownloadFileModel *model;

// 开始下载回调
@property (nonatomic, copy) void (^downloadStartBlock)(void);

// 暂停下载回调
@property (nonatomic, copy) void (^downloadPauseBlock)(void);

// 继续下载回调
@property (nonatomic, copy) void (^downloadResumeBlock)(void);

// 播放回调
@property (nonatomic, copy) void (^playBlock)(void);

@end

NS_ASSUME_NONNULL_END
