//
//  HYPlayVideoController.h
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPresentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYPlayVideoBaseController : HYPresentViewController

// 背景视图
@property (nonatomic, strong, readonly) UIView *bgView;

// 播放器背景视图
@property (nonatomic, strong, readonly) UIView *playerBgView;

// 视频模型
@property (nonatomic, weak) HYBaseVideoModel *videoModel;

// 是否显示自定义的播放控制视图
@property (nonatomic, assign) BOOL showCustomControlViews;

// 准备好播放回调
@property (nonatomic, copy) void (^preparedPlayBlock)(void);

// 播放回调
@property (nonatomic, copy) void (^playBlock)(void);

// 暂停播放回调
@property (nonatomic, copy) void (^pauseBlock)(void);

/**
 * 创建播放控制视图
 */
- (void)createPlayControlViews;

@end

NS_ASSUME_NONNULL_END
