//
//  HYMovieThumbnailImageListCell.h
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoThumbnailListCell : HYVideoBaseCell

/**
 * 开始加载
 */
- (void)startLoading;

/**
 * 停止加载
 */
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
