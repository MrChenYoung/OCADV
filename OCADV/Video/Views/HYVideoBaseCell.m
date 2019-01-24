//
//  HYMovieBaseCell.m
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoBaseCell.h"

@interface HYVideoBaseCell ()

// 显示视频缩略图的imageView
@property (nonatomic, strong, readwrite) UIImageView *thumbnailImageView;

// 加载菊花
@property (nonatomic, strong, readwrite) UIActivityIndicatorView *loadingView;

// 菜单栏背景
@property (nonatomic, strong, readwrite) UIView *menuBgView;

// 视频大小
@property (nonatomic, strong, readwrite) UILabel *videoLengthLabel;

@end

@implementation HYVideoBaseCell

#pragma mark - 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // 创建子视图
        [self createSubView];
    }
    
    return self;
}

#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubView
{
    // 创建缩略图imageView
    self.thumbnailImageView = [[UIImageView alloc]init];
    self.thumbnailImageView.userInteractionEnabled = YES;
    [self addSubview:self.thumbnailImageView];
    // 添加点击手势，点击播放
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapThumbnailAction)];
    [self.thumbnailImageView addGestureRecognizer:tap];
    
    // 创建加载视图
    self.loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingView.hidesWhenStopped = YES;
    [self addSubview:self.loadingView];
    
    // 创建菜单栏
    self.menuBgView = [[UIView alloc]init];
    self.menuBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.menuBgView];
    
    // 视频大小label
    self.videoLengthLabel = [[UILabel alloc]init];
    self.videoLengthLabel.textAlignment = NSTextAlignmentCenter;
    self.videoLengthLabel.textColor = [UIColor whiteColor];
    self.videoLengthLabel.font = [UIFont systemFontOfSize:12.0];
    [self.menuBgView addSubview:self.videoLengthLabel];
}

/**
 * 更新subviewFrame
 */
- (void)updateSubViewFrame
{
    self.frame = CGRectMake(0, 0, self.model.naturalSize.width, self.model.naturalSize.height);
    
    // 缩略图
    self.thumbnailImageView.frame = CGRectMake(0, 0, self.model.naturalSize.width, self.model.naturalSize.height);
    
    // 加载视图
    self.loadingView.center = CGPointMake(self.model.naturalSize.width * 0.5, self.model.naturalSize.height * 0.5);
    
    // 菜单栏frame
    CGFloat menuBgHeight = 30.0;
    CGFloat menuBgY = self.bounds.size.height - menuBgHeight;
    self.menuBgView.frame = CGRectMake(0, menuBgY, self.bounds.size.width, menuBgHeight);
    
    // 视频大小
    self.videoLengthLabel.frame = CGRectMake(5.0, 0.0, 60.0, menuBgHeight);
}

#pragma mark - action
/**
 * 点击视频缩略图
 */
- (void)tapThumbnailAction
{
    if (self.tapThumbnailBlock) {
        self.tapThumbnailBlock();
    }
}

@end
