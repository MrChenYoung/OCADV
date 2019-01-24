//
//  HYVideoThumbnailImageView.m
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoThumbnailView.h"

@interface HYVideoThumbnailView ()

// 背景视图
@property (nonatomic, weak, readwrite) UIView *bgView;

// 图片
@property (nonatomic, weak, readwrite) UIImageView *imageView;

// 标题
@property (nonatomic, weak, readwrite) UILabel *titleLabel;

// 加载菊花
@property (nonatomic, weak, readwrite) UIActivityIndicatorView *loadingView;

// 播放图片
@property (nonatomic, weak, readwrite) UIImageView *playImageView;

@end

@implementation HYVideoThumbnailView

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 创建子视图
        [self createSuviews];
    }
    return self;
}

/**
 * 创建子视图
 */
- (void)createSuviews
{
    self.clipsToBounds = YES;
    CGFloat imageW = (ScWidth - 20.0 - 10.0) / 3.0;
    CGFloat imageH = imageW / 150.0 * 100.0;
    self.frame = CGRectMake(0, 0, imageW, imageH + 30.0);
    
    // 背景视图
    UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:bgView];
    self.bgView = bgView;

    
    // 图片视图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imageW, imageH)];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [UIImage imageNamed:@"emptyVideo"];
    imageView.backgroundColor = ColorLightGray;
    [self.bgView addSubview:imageView];
    self.imageView = imageView;
    // 添加点击手势，点击播放
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageViewAction)];
    [self.imageView addGestureRecognizer:tap];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), CGRectGetWidth(imageView.frame), 30.0)];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = ColorDefaultText;
    [self.bgView addSubview:titleLabel];
    titleLabel.text = @"标题";
    self.titleLabel = titleLabel;
    
    // 加载菊花
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(imageW * 0.5, imageH * 0.5);
    [activityView startAnimating];
    [self.bgView addSubview:activityView];
    self.loadingView = activityView;
    
    // 播放图片
    UIImageView *playImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play"]];
    playImageView.hidden = YES;
    [self.bgView addSubview:playImageView];
    playImageView.frame = CGRectMake(0, 0, 40.0, 40.0);
    playImageView.center = activityView.center;
    self.playImageView = playImageView;
}

#pragma mark - setter
/**
 * 绑定数据
 */
- (void)setModel:(HYBaseVideoModel *)model
{
    _model = model;
    
    // 标题
    self.titleLabel.text = model.title;
    
    // 开始获取缩略图
    if (model.thumbnail == nil) {
        [model loadVideoThumbnailComplete:nil];
        model.loadThumbnailBlock = ^(UIImage * _Nonnull image) {
            // 停止加载缩略图
            [self.loadingView stopAnimating];
            self.playImageView.hidden = NO;
            
            if (image) {
                self.imageView.contentMode = UIViewContentModeScaleAspectFill;
                self.imageView.image = image;
            }
        };
    }else {
        [self.loadingView stopAnimating];
        self.playImageView.hidden = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.image = model.thumbnail;
    }
}

#pragma mark - action
/**
 * 点击图片
 */
- (void)tapImageViewAction
{
    if (self.tapImageViewBlock) {
        self.tapImageViewBlock();
    }
}

@end
