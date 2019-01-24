//
//  HYUploadView.h
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYUploadImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYUploadView : UIView

// 更新后的imageModel
@property (nonatomic, weak) HYUploadImageModel *updatedImageModel;

// 所有的imageView
@property (nonatomic, strong, readonly) NSMutableArray <HYUploadImageView *>*imageViewListArray;

// 上传照片回调
@property (nonatomic, copy) void (^uploadImageBlock)(HYUploadImageModel *imageModel);

// 查看上传过的图片
@property (nonatomic, copy) void(^checkUploadedImage)(HYUploadImageModel *imageModel,UIImageView *imageView);

/**
 * 初始化
 */
- (instancetype)initWithY:(CGFloat)y;

/**
 * 销毁用到的timer 否则影响内存释放
 */
- (void)destroyTimer;

@end

NS_ASSUME_NONNULL_END
