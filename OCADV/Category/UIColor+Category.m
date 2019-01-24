//
//  UIColor+Category.m
//  OCADV
//
//  Created by MrChen on 2019/1/13.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

/**
 * 根据进度获取渐变色
 * progress 进度
 * fromColor 开始颜色
 * toColor 结束颜色
 */
+ (UIColor *)colorWithProgress:(CGFloat)progress fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor
{
    // 创建渐变view
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIView *gradientView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, 2.0)];
    
    // 渐变layer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor, (__bridge id)toColor.CGColor];
    gradientLayer.locations = @[@0.0, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1.0, 0);
    gradientLayer.frame = gradientView.bounds;
    [gradientView.layer addSublayer:gradientLayer];
    
    
    CGPoint point = CGPointMake(screenSize.width * progress, 1.0);
    if (point.x <= 0) {
        point.x = 1.0;
    }else if (point.x >= CGRectGetWidth(gradientView.frame)){
        point.x = CGRectGetWidth(gradientView.frame) - 1.0;
    }
    
    UIColor *resultColor = [gradientView colorOfPoint:point];
    return resultColor;
}

@end

