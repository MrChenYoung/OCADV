//
//  MyButton.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYButton.h"

@interface HYButton ()

// 按钮当前的文字
@property (nonatomic, copy) NSString *currentText;

// 等待加载的indicatorView
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;
@end

@implementation HYButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat leftPadding = 10;
        CGFloat btnW = [UIScreen mainScreen].bounds.size.width - leftPadding * 2;
        CGFloat btnH = 40;
        
        self.frame = CGRectMake(leftPadding, 0, btnW, btnH);
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.backgroundColor = ColorMain;
        [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
        // 创建activityIndicator
        _loadingIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_loadingIndicatorView];
    }
    return self;
}

/**
 * 显示等待loadingView
 */
- (void)showLoadingView:(NSString *)loadingText
{
    [self setTitle:loadingText forState:UIControlStateNormal];
    [self setTitle:loadingText forState:UIControlStateHighlighted];
    
    self.clickAble = false;
    [self.loadingIndicatorView startAnimating];
    
    CGRect frame = self.loadingIndicatorView.frame;
    frame.origin.y = (self.bounds.size.height - frame.size.height) * 0.5;
    frame.origin.x = self.titleLabel.frame.origin.x - CGRectGetWidth(self.loadingIndicatorView.frame) - 3;
    self.loadingIndicatorView.frame = frame;
}

/**
 * 隐藏loadingView
 */
- (void)hiddenLoadingView
{
    self.clickAble = YES;
    self.titleText = self.currentText;
    [self.loadingIndicatorView stopAnimating];
}

/**
 * 获取按钮的y坐标
 */
- (CGFloat)btnY
{
    return self.frame.origin.y;
}

/**
 * 设置按钮y坐标
 */
- (void)setBtnY:(CGFloat)btnY
{
    CGRect frame = self.frame;
    frame.origin.y = btnY;
    self.frame = frame;
}

/**
 * 获取按钮的标题
 */
- (NSString *)titleText
{
    return self.titleLabel.text;
}

/**
 * 设置标题
 */
- (void)setTitleText:(NSString *)titleText
{
    [self setTitle:titleText forState:UIControlStateNormal];
    [self setTitle:titleText forState:UIControlStateHighlighted];
    self.currentText = titleText;
}

/**
 * 获取按钮可点击状态
 */
- (BOOL)clickAble
{
    return self.enabled;
}

/**
 * 设置按钮可点击状态
 */
- (void)setClickAble:(BOOL)clickAble
{
    self.enabled = clickAble;
}



@end
