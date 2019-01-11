//
//  HYUploadView.h
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYUploadView : UIView
// 上传照片回调
@property (nonatomic, copy) void (^uploadImageBlock)(HYUploadImageModel *imageModel);

// 上传进度改变回调
@property (nonatomic, copy) void (^uploadProgressBlock)(CGFloat progress,NSInteger imageIndex);

// 更新后的imageModel
@property (nonatomic, weak) HYUploadImageModel *updatedImageModel;

// 查看上传过的图片
@property (nonatomic, copy) void(^checkUploadedImage)(NSString *imageUrl,UIImageView *imageView);

/**
 * 初始化
 */
- (instancetype)initWithY:(CGFloat)y;

- (void)destroyTimer;

@end

NS_ASSUME_NONNULL_END
