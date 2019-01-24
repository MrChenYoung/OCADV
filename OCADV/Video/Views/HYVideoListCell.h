//
//  HYMovieCell.h
//  OCADV
//
//  Created by MrChen on 2019/1/18.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYVideoBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoListCell : HYVideoBaseCell

// 查看图片列表按钮点击
@property (nonatomic, copy) void (^imageListBtnClickBlock)(void);

// 缩略图加载完成回调
@property (nonatomic, copy) void (^loadThumbnailComplete)(void);

@end

NS_ASSUME_NONNULL_END
