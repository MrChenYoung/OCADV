//
//  UIColor+Category.h
//  OCADV
//
//  Created by MrChen on 2019/1/13.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Category)

/**
 * 根据进度获取渐变色
 * progress 进度
 * fromColor 开始颜色
 * toColor 结束颜色
 */
+ (UIColor *)colorWithProgress:(CGFloat)progress fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

@end

NS_ASSUME_NONNULL_END
