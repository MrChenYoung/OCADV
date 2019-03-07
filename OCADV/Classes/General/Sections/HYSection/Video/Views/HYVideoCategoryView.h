//
//  HYVideoCategoryView.h
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYVideoThumbnailView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoCategoryView : UIView

// 视频来源(标题)
@property (nonatomic, copy) NSString *videoSource;

// 视频集合
@property (nonatomic, strong) NSArray <HYBaseVideoModel *>*videos;

// 点击回调
@property (nonatomic, copy) void (^tapBlock)(void);

// 播放视频回调
@property (nonatomic, copy) void (^playBlock)(HYVideoThumbnailView *thubnailView);

/**
 * 创建视频缩略图
 */
- (void)addVideoThumbnailImageViewWithModel:(HYBaseVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
