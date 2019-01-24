//
//  HYMovieBaseCell.h
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoBaseCell : UITableViewCell

// 显示视频缩略图的imageView
@property (nonatomic, strong, readonly) UIImageView *thumbnailImageView;

// 加载菊花
@property (nonatomic, strong, readonly) UIActivityIndicatorView *loadingView;

// 菜单栏背景
@property (nonatomic, strong, readonly) UIView *menuBgView;

// 视频大小
@property (nonatomic, strong, readonly) UILabel *videoLengthLabel;

// 数据模型
@property (nonatomic, weak) HYBaseVideoModel *model;

// 点击缩略图回调
@property (nonatomic, copy) void (^tapThumbnailBlock)(void);

/**
 * 创建子视图
 */
- (void)createSubView;

/**
 * 更新subviewFrame
 */
- (void)updateSubViewFrame;

@end

NS_ASSUME_NONNULL_END
