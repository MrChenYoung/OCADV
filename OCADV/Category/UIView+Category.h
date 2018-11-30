//
//  UIView+Category.h
//  Deppon
//
//  Created by MrChen on 2017/12/7.
//  Copyright © 2017年 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)

@property (assign, nonatomic) CGFloat viewX;
@property (assign, nonatomic) CGFloat viewY;
@property (assign, nonatomic) CGFloat viewMaxX;
@property (assign, nonatomic) CGFloat viewMaxY;
@property (assign, nonatomic) CGFloat viewWidth;
@property (assign, nonatomic) CGFloat viewHeight;
@property (assign, nonatomic) CGSize viewSize;
@property (assign, nonatomic) CGPoint viewOrigin;
@property (nonatomic, assign) CGFloat viewCenterX;
@property (nonatomic, assign) CGFloat viewCenterY;

/**
 * 设置view背景色渐变
 * colors 渐变色
 * fromPoint 起始位置
 * toPoint 终点位置
 * 注: (0,0)~(1,0) 水平方向渐变,(0,0)~(0,1)垂直方向渐变
 */
- (void)backGroundColorGraded:(NSArray <UIColor *>*)colors fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;

/**
 * 获取当前View的控制器对象
 */
-(UIViewController *)getCurrentViewController;

- (void)makeToastActivity;

- (void)hideToastActivity;


@end
