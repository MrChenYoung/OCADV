//
//  HYVideoThumbnailImageView.h
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoThumbnailView : UIView
// 加载菊花
@property (nonatomic, weak, readonly) UIActivityIndicatorView *loadingView;

// 播放图片
@property (nonatomic, weak, readonly) UIImageView *playImageView;

// 数据模型
@property (nonatomic, weak) HYBaseVideoModel *model;

// 点击图片回调，播放视频
@property (nonatomic, copy) void (^tapImageViewBlock)(void);
@end

NS_ASSUME_NONNULL_END
