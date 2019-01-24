//
//  HYVideoCategoryView.m
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoCategoryView.h"

@interface HYVideoCategoryView ()

// 来源(标题)
@property (nonatomic, strong) UILabel *sourceLabel;

// 没有视频提示
@property (nonatomic, strong) UILabel *emptyVideoLabel;

// 查看全部
@property (nonatomic, strong) UILabel *checkAllLabel;
@property (nonatomic, strong) UIImageView *checkAllImageView;

// 显示的所有视频封面
@property (nonatomic, strong) UIView *videoBgView;
@property (nonatomic, strong) NSMutableArray <HYVideoThumbnailView *>*videoThumbnailImageViews;

@property (nonatomic, strong) NSMutableArray *addedVideoModels;

@end

@implementation HYVideoCategoryView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScWidth, 80.0);
        self.videoThumbnailImageViews = [NSMutableArray array];
        self.addedVideoModels = [NSMutableArray array];
        
        // 创建子视图
        [self createSubview];
    }
    return self;
}

#pragma mark - setter
/**
 * 设置视频数据
 */
- (void)setVideos:(NSArray<HYNormalVideoModel *> *)videos
{
    _videos = videos;
    
    for (HYBaseVideoModel *model in videos) {
        if (![self.addedVideoModels containsObject:model]) {
            [self addVideoThumbnailImageViewWithModel:model];
        }
    }
}

/**
 * 视频来源
 */
- (void)setVideoSource:(NSString *)videoSource
{
    _videoSource = videoSource;
    self.sourceLabel.text = videoSource;
}

#pragma mark - custoem method
/**
 * 创建子视图
 */
- (void)createSubview
{
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    // 来源(标题)
    self.sourceLabel = [[UILabel alloc]init];
    self.sourceLabel.textColor = ColorDefaultText;
    self.sourceLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self addSubview:self.sourceLabel];
    
    // 没有视频提示文字
    self.emptyVideoLabel = [[UILabel alloc]init];
    self.emptyVideoLabel.textColor = ColorLightGray;
    self.emptyVideoLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.emptyVideoLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyVideoLabel.text = @"暂无视频";
    self.emptyVideoLabel.backgroundColor = ColorGrayBg;
    [self addSubview:self.emptyVideoLabel];
    
    // 查看全部
    self.checkAllLabel = [[UILabel alloc]init];
    self.checkAllLabel.textColor = ColorLightGray;
    self.checkAllLabel.font = [UIFont systemFontOfSize:12.0];
    self.checkAllLabel.textAlignment = NSTextAlignmentRight;
    self.checkAllLabel.text = @"查看全部";
    [self addSubview:self.checkAllLabel];
    self.checkAllImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"checkAll"]];
    [self addSubview:self.checkAllImageView];
    
    // 显示的所有视频封面
    self.videoBgView = [[UIView alloc]init];
    [self addSubview:self.videoBgView];
    
    [self updateFrames];
}


/**
 * 创建视频缩略图
 */
- (void)addVideoThumbnailImageViewWithModel:(HYBaseVideoModel *)model
{
    // 记录已经添加过的model 防止在setModel里重复添加
    if (![self.addedVideoModels containsObject:model]) {
        [self.addedVideoModels addObject:model];
    }
    
    if (![self.videos containsObject:model]) {
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.videos];
        [arrM addObject:model];
        self.videos = [arrM copy];
    }
    
    if (self.videoThumbnailImageViews.count < 3) {
        HYVideoThumbnailView *imageView = [[HYVideoThumbnailView alloc]init];
        imageView.model = model;
        __weak typeof(HYVideoThumbnailView *) weakImageView = imageView;
        imageView.tapImageViewBlock = ^{
            // 点击图片回调 播放视频
            if (self.playBlock) {
                self.playBlock(weakImageView);
            }
        };
        [self.videoBgView addSubview:imageView];
        [self.videoThumbnailImageViews addObject:imageView];
    }
    
    // 设置frame
    [self updateFrames];
}

/**
 * 设置frame
 */
- (void)updateFrames
{
    // 来源(标题)
    self.sourceLabel.frame = CGRectMake(10.0, 0.0, ScWidth - 20.0, 20.0);
    
    // 查看全部
    BOOL showCheckAllLabel = self.videos.count > 3 ? YES : NO;
    self.checkAllLabel.hidden = self.checkAllImageView.hidden = !showCheckAllLabel;
    self.checkAllImageView.frame = CGRectMake(ScWidth - 10.0 - 10.0, CGRectGetMaxY(self.sourceLabel.frame), 10.0, 10.0);
    self.checkAllLabel.frame = CGRectMake(10.0, CGRectGetMaxY(self.sourceLabel.frame), CGRectGetMinX(self.checkAllImageView.frame) - 10.0, 10.0);
    
    // 视频封面
    CGFloat imageY = showCheckAllLabel ? CGRectGetMaxY(self.checkAllLabel.frame) + 5.0 : CGRectGetMaxY(self.sourceLabel.frame) + 5.0;
    CGFloat imageW = (ScWidth - 20.0 - 10.0) / 3.0;
    CGFloat imageH = imageW / 150.0 * 100.0 + 30.0;
    self.videoBgView.frame = CGRectMake(0, imageY, ScWidth, imageH);
    for (int index = 0; index < self.videoThumbnailImageViews.count; index++) {
        HYVideoThumbnailView *imageView = self.videoThumbnailImageViews[index];
        CGFloat imageX = 10.0 + (imageW + 5.0) * index;
        imageView.viewX = imageX;
    }
    
    // 没有视频提示文字
    self.emptyVideoLabel.frame = self.videoBgView.frame;
    if (self.videoThumbnailImageViews.count > 0) {
        // 有视频
        self.emptyVideoLabel.hidden = YES;
    }else {
        // 有视频
        self.emptyVideoLabel.hidden = NO;
    }
    
    self.viewHeight = CGRectGetMaxY(self.videoBgView.frame);
}

#pragma mark - action
/**
 * 点击手势事件
 */
- (void)tapAction
{
    if (self.videoThumbnailImageViews.count > 0) {
        // 进入视频列表页面
        if (self.tapBlock) {
            self.tapBlock();
        }
    }
}
@end
