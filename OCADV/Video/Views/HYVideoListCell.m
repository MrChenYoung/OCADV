//
//  HYMovieCell.m
//  OCADV
//
//  Created by MrChen on 2019/1/18.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoListCell.h"

@interface HYVideoListCell ()

// 播放图标
@property (nonatomic, strong) UIImageView *playImageView;

// 视频总时长
@property (nonatomic, strong) UILabel *durationLabel;

// 查看视频包含的所有图片按钮
@property (nonatomic, strong) UIButton *imageListButton;

// 视频包含的缩略图数量显示
@property (nonatomic, strong) UILabel *thumbnailCountLabel;

@end

@implementation HYVideoListCell

#pragma mark - 初始化
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubView
{
    [super createSubView];
    
    // 创建播放按钮
    self.playImageView = [[UIImageView alloc]init];
    [self addSubview:self.playImageView];
    
    // 视频总时长
    self.durationLabel = [[UILabel alloc]init];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.font = [UIFont systemFontOfSize:12.0];
    [self.menuBgView addSubview:self.durationLabel];
    
    // 查看视频包含的所有图片按钮
    self.imageListButton = [[UIButton alloc]init];
    [self.imageListButton addTarget:self action:@selector(checkImageList) forControlEvents:UIControlEventTouchUpInside];
    [self.imageListButton setBackgroundImage:[UIImage imageNamed:@"imageList"] forState:UIControlStateNormal];
    [self.menuBgView addSubview:self.imageListButton];
    
    // 视频包含的缩略图数量显示
    self.thumbnailCountLabel = [[UILabel alloc]init];
    self.thumbnailCountLabel.textColor = [UIColor whiteColor];
    self.thumbnailCountLabel.font = [UIFont systemFontOfSize:12.0];
    self.thumbnailCountLabel.textAlignment = NSTextAlignmentRight;
    [self.menuBgView addSubview:self.thumbnailCountLabel];
}

/**
 * 更新subviewFrame
 */
- (void)updateSubViewFrame
{
    [super updateSubViewFrame];
    
    // 播放按钮
    self.playImageView.frame = CGRectMake(0, 0, 50, 50);
    self.playImageView.center = CGPointMake(self.model.naturalSize.width * 0.5, self.model.naturalSize.height * 0.5);
    
    // 视频时长
    CGFloat menuBgHeight = CGRectGetHeight(self.menuBgView.frame);
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.videoLengthLabel.frame) + 10.0, 0.0, 100.0, menuBgHeight);
    
    // 查看视频包含的所有图片按钮frame
    CGFloat imgListW = 20.0;
    CGFloat imgListH = imgListW;
    CGFloat imgListX = CGRectGetWidth(self.menuBgView.frame) - 10.0 - imgListW;
    CGFloat imgListY = (CGRectGetHeight(self.menuBgView.frame) - imgListH) * 0.5;
    self.imageListButton.frame = CGRectMake(imgListX, imgListY, imgListW, imgListH);

    // 视频包含的缩略图数量显示
    CGFloat countLabelW = 100.0;
    CGFloat countLabelX = CGRectGetMinX(self.imageListButton.frame) - 5.0 - countLabelW;
    CGFloat countLabelY = imgListY;
    CGFloat countLabelH = imgListH;
    self.thumbnailCountLabel.frame = CGRectMake(countLabelX, countLabelY, countLabelW, countLabelH);
}

/**
 * 当获取到视频尺寸的时候刷新当前cell
 */
- (void)reloadTableView
{
    UITableView *tableView = [self tableView];
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    if (indexPath != nil) {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self updateSubViewFrame];
    }
}

/**
 * 获取cell的tableView
 */
- (UITableView *)tableView
{
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView) {
        tableView = tableView.superview;
    }
    
    return (UITableView *)tableView;
}

/**
 * 刷新播放状态
 */
- (void)reloadPlayStatus
{
    // 播放状态
    switch (self.model.playStatus) {
        case videoPlayStatusLoadingThumbnail:
            // 加载缩略图中
            self.playImageView.hidden = YES;
            [self.loadingView startAnimating];
            break;
        case videoPlayStatusLoadThumbnailComplete:
            // 缩略图加载完成
            self.playImageView.hidden = NO;
            [self.loadingView stopAnimating];
            self.playImageView.image = [UIImage imageNamed:@"play"];
            break;
        default:
            break;
    }
}

#pragma mark - setter
/**
 * 绑定数据
 */
- (void)setModel:(HYBaseVideoModel *)model
{
    [super setModel:model];
    
    __weak typeof(HYBaseVideoModel *) weakModel = model;
    // 设置imageSize
    if (model.naturalSize.width == 0 || model.naturalSize.height == 0) {
        [model loadVideoNaturalSizeComplete:nil];
        model.loadVideoNaturalSizeBlock = ^(CGSize videoSize) {
            [self reloadTableView];
            self.thumbnailImageView.viewSize = weakModel.naturalSize;
        };
    }else {
        self.thumbnailImageView.viewSize = model.naturalSize;
    }
    
    // 设置缩略图
    if (model.thumbnail == nil) {
        [model loadVideoThumbnailComplete:nil];
        model.loadThumbnailBlock = ^(UIImage * _Nonnull image) {
            self.thumbnailImageView.image = image;
            
            // 加载缩略图完成
            weakModel.playStatus = videoPlayStatusLoadThumbnailComplete;
            [self reloadPlayStatus];
            
            if (self.loadThumbnailComplete) {
                self.loadThumbnailComplete();
            }
        };
    }else {
        self.thumbnailImageView.image = model.thumbnail;
        weakModel.playStatus = videoPlayStatusLoadThumbnailComplete;
        [self reloadPlayStatus];
    }
    
    
    // 设置视频时长
    if (model.totalDuration <= 0) {
        [model loadVideoDurationComplete:nil];
        model.loadVideoDurationBlock = ^(NSString * _Nonnull durationFormat) {
            self.durationLabel.text = durationFormat;
            self.thumbnailCountLabel.text = [NSString stringWithFormat:@"%.f",weakModel.totalDuration];
        };
    }else {
        self.durationLabel.text = model.totalDurationFormat;
        self.thumbnailCountLabel.text = [NSString stringWithFormat:@"%.f",model.totalDuration];
    }
    
    // 设置视频占用存储空间大小
    if (model.videoLength <= 0) {
        [model loadVideoLengthComplete:nil];
        model.loadVideoLengthBlock = ^(NSString * _Nonnull lengthFormate) {
            self.videoLengthLabel.text = lengthFormate;
        };
    }else {
        self.videoLengthLabel.text = model.videoLengthFormat;
    }
    
    // 刷新播放状态
    [self reloadPlayStatus];
    
    // 刷新界面空间frame
    [self updateSubViewFrame];
}

#pragma mark - lazy loading


#pragma mark - click action
// 查看视频包含的所有图片
- (void)checkImageList
{
    if (self.imageListBtnClickBlock) {
        self.imageListBtnClickBlock();
    }
}

@end
