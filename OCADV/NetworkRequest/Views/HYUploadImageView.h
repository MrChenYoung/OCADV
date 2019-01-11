//
//  HYUploadImageView.h
//  OCADV
//
//  Created by MrChen on 2019/1/4.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYUploadImageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYUploadImageView : UIImageView

// 开始上传照片回调
@property (nonatomic, copy) void (^startUploadImageBlock)(void);

// 查看上传过的图片
@property (nonatomic, copy) void(^checkUploadedImage)(NSString *imageUrl);

// 数据模型
@property (nonatomic, strong) HYUploadImageModel *model;

/**
 * 根据百分比更新进度条进度
 */
- (void)updateProgressViewPersent:(double)persent;

/**
 * 销毁计时器 在控制器销毁的时候销毁计时器,否侧影响当前类实例对象的销毁
 */
- (void)destroyTimer;

@end

NS_ASSUME_NONNULL_END
