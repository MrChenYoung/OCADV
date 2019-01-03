//
//  UIView+Category.m
//  Deppon
//
//  Created by MrChen on 2017/12/7.
//  Copyright © 2017年 MrChen. All rights reserved.
//

static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString * CSToastActivityDefaultPosition = @"center";
static const CGFloat CSToastActivityWidth       = 100.0;
static const CGFloat CSToastActivityHeight      = 100.0;
static const CGFloat CSToastOpacity             = 0.4;
static const CGFloat CSToastCornerRadius        = 10.0;
static const CGFloat CSToastShadowOpacity       = 0.4;
static const BOOL    CSToastDisplayShadow       = YES;
static const CGFloat CSToastShadowRadius        = 6.0;
static const CGSize  CSToastShadowOffset        = { 4.0, 4.0 };
static const CGFloat CSToastFadeDuration        = 0.2;
static const CGFloat CSToastVerticalPadding     = 10.0;
static const NSString * CSToastDefaultPosition  = @"bottom";

#import "UIView+Category.h"
#import <objc/runtime.h>

@implementation UIView (Category)
#pragma mark - frame相关
- (void)setViewX:(CGFloat)viewX
{
    CGRect frame = self.frame;
    frame.origin.x = viewX;
    self.frame = frame;
}

- (CGFloat)viewX
{
    return self.frame.origin.x;
}

- (void)setViewY:(CGFloat)viewY
{
    CGRect frame = self.frame;
    frame.origin.y = viewY;
    self.frame = frame;
}

- (CGFloat)viewY
{
    return self.frame.origin.y;
}

- (void)setViewMaxX:(CGFloat)viewMaxX
{
    CGRect frame = self.frame;
    frame.origin.x = viewMaxX - frame.size.width;
    self.frame = frame;
}

- (CGFloat)viewMaxX
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setViewMaxY:(CGFloat)viewMaxY
{
    CGRect frame = self.frame;
    frame.origin.y = viewMaxY - frame.size.height;
    self.frame = frame;
}

- (CGFloat)viewMaxY
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setViewWidth:(CGFloat)viewWidth
{
    CGRect frame = self.frame;
    frame.size.width = viewWidth;
    self.frame = frame;
}

- (CGFloat)viewWidth
{
    return self.frame.size.width;
}

- (void)setViewHeight:(CGFloat)viewHeight
{
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
}

- (CGFloat)viewHeight
{
    return self.frame.size.height;
}

- (void)setViewSize:(CGSize)viewSize
{
    CGRect frame = self.frame;
    frame.size = viewSize;
    self.frame = frame;
}

- (CGSize)viewSize
{
    return self.frame.size;
}

- (void)setViewOrigin:(CGPoint)viewOrigin
{
    CGRect frame = self.frame;
    frame.origin = viewOrigin;
    self.frame = frame;
}

- (CGPoint)viewOrigin
{
    return self.frame.origin;
}

- (void)setViewCenterX:(CGFloat)viewCenterX
{
    CGPoint center = self.center;
    center.x = viewCenterX;
    self.center = center;
}

- (CGFloat)viewCenterX
{
    return self.center.x;
}

- (void)setViewCenterY:(CGFloat)viewCenterY
{
    CGPoint center = self.center;
    center.y = viewCenterY;
    self.center = center;
}

- (CGFloat)viewCenterY
{
    return self.center.y;
}

#pragma mark - 设置背景色渐变
/**
 * 设置view背景色渐变
 * colors 渐变色
 * fromPoint 起始位置
 * toPoint 终点位置
 * 注: (0,0)~(1,0) 水平方向渐变,(0,0)~(0,1)垂直方向渐变
 */
- (void)backGroundColorGraded:(NSArray <UIColor *>*)colors fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    // 设置颜色渐变
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    NSMutableArray *colorsM = [NSMutableArray array];
    for (UIColor *col in colors) {
        CGColorRef transColor = col.CGColor;
        [colorsM addObject:((__bridge id)transColor)];
    }
    gradientLayer.colors = colorsM;
    
    //位置x,y    自己根据需求进行设置   使其从不同位置进行渐变
    gradientLayer.startPoint = fromPoint;
    gradientLayer.endPoint = toPoint;
    gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:gradientLayer];
}

#pragma mark - 获取当前View的控制器对象
/** 获取当前View的控制器对象 */
- (UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

#pragma mark - Toast Activity Methods
- (void)makeToastActivity {
    [self makeToastActivity:CSToastActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:CSToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = CSToastCornerRadius;
    
    if (CSToastDisplayShadow) {
        activityView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        activityView.layer.shadowOpacity = CSToastShadowOpacity;
        activityView.layer.shadowRadius = CSToastShadowRadius;
        activityView.layer.shadowOffset = CSToastShadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate ourselves with the activity view
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast {
    if([point isKindOfClass:[NSString class]]) {
        // convert string literals @"top", @"bottom", @"center", or any point wrapped in an NSValue object into a CGPoint
        if([point caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + CSToastVerticalPadding);
        } else if([point caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)-48) - CSToastVerticalPadding);
        } else if([point caseInsensitiveCompare:@"center"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
//    DPMLog(@"Warning: Invalid position for toast.");
    return [self centerPointForPosition:CSToastDefaultPosition withToast:toast];
}

#pragma mark - 把view转换成图片
/**
 * 根据View生成图片
 */
- (UIImage *)toImage
{
    return [self toImageFromReact:self.bounds];;
}

/**
 * 根据View在指定位置生成指定大小的图片
 */
- (UIImage *)toImageFromReact:(CGRect)react
{
    // 根据view获取图片
    CGSize viewSize = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, YES, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 根据react裁剪图片
    image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, react)];
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 获取和view大小相同的毛玻璃后效果view
/**
 * 获取和view大小相同的毛玻璃后效果view
 */
- (UIView *)blurEffectView
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    blurEffectView.alpha = 1;
    return blurEffectView;
}

@end
