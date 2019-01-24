//
//  HYDownloadView.m
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYDownloadView.h"

@interface HYDownloadView ()

// 背景视图
@property (nonatomic, weak) UIView *bgView;

// 标题
@property (nonatomic, weak) UILabel *titleLabel;

// 下载/播放按钮
@property (nonatomic, weak) UIButton *downloadBtn;

// 下载进度条
@property (nonatomic, weak) UIProgressView *progressView;

// 下载百分比显示
@property (nonatomic, weak) UILabel *downloadPercentLabel;

// 时长显示
@property (nonatomic, weak) UILabel *durationLabel;

// 总大小和已经下载的大小
@property (nonatomic, weak) UILabel *downloadSizeLabel;

@end

@implementation HYDownloadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建子视图
        [self createSubViews];
    }
    return self;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    // 背景视图
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = ColorMain;
    bgView.layer.cornerRadius = 8;
    [self addSubview:bgView];
    self.bgView = bgView;
    
    // 标题label
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.numberOfLines = 0;
    titleLabel.text = @"";
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [UIColor whiteColor];
    [bgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // 下载进度条
    UIProgressView *progress = [[UIProgressView alloc]init];
    progress.progress = 0.0;
    progress.trackTintColor = [UIColor whiteColor];
    [bgView addSubview:progress];
    self.progressView = progress;
    
    // 下载百分比显示
    UILabel *downloadProgressLabel = [[UILabel alloc]init];
    downloadProgressLabel.textColor = [UIColor whiteColor];
    downloadProgressLabel.font = [UIFont systemFontOfSize:14.0];
    downloadProgressLabel.text = @"未下载";
    [bgView addSubview:downloadProgressLabel];
    self.downloadPercentLabel = downloadProgressLabel;
    
    // 视频时长label
    UILabel *durationLabel = [[UILabel alloc]init];
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.font = [UIFont systemFontOfSize:14.0];
    durationLabel.text = @"0s";
    durationLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:durationLabel];
    self.durationLabel = durationLabel;
    
    // 总大小和已经下载大小
    UILabel *downloadSizeLabel = [[UILabel alloc]init];
    downloadSizeLabel.text = @"0KB/0KB";
    downloadSizeLabel.textColor = [UIColor whiteColor];
    downloadSizeLabel.font = [UIFont systemFontOfSize:14.0];
    downloadSizeLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:downloadSizeLabel];
    self.downloadSizeLabel = downloadSizeLabel;
    
    // 下载/播放按钮
    UIButton *downloadBtn = [[UIButton alloc]init];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:downloadBtn];
    self.downloadBtn = downloadBtn;
    
    // 更新frame
    [self updateFrames];
}

/**
 * 更新frame
 */
- (void)updateFrames
{
    // 计算self的高度
    CGFloat padding = 5.0;
    CGFloat normalSubViewHeigth = 30.0;
    CGFloat downloadBtnW = 40.0;
    CGFloat progressHeight = CGRectGetHeight([[UIProgressView alloc]init].frame);
    
    // 标题的高度
    CGFloat titleLebelW = self.bounds.size.width - downloadBtnW - padding * 4.0;
    CGFloat titleH = [self.titleLabel.text sizeWithFont:self.titleLabel.font maxSize:CGSizeMake(titleLebelW, 1000)].height;
    if (titleH < normalSubViewHeigth) {
        titleH = normalSubViewHeigth;
    }
    CGRect frame = self.frame;
    frame.size.height = padding * 4.0 + progressHeight + normalSubViewHeigth + titleH;
    self.frame = frame;
    
    // 背景视图frame
    self.bgView.frame = self.bounds;
    
    // 标题label frame
    self.titleLabel.frame = CGRectMake(padding, padding, titleLebelW, titleH);

    // 下载进度条frame
    CGFloat progressY = CGRectGetMaxY(self.titleLabel.frame) + padding;
    self.progressView.frame = CGRectMake(padding, progressY, titleLebelW, progressHeight);
    
    // 下载百分比显示frame
    CGFloat labelW = CGRectGetWidth(self.progressView.frame) / 3;
    CGFloat labelH = normalSubViewHeigth;
    CGFloat labelX = CGRectGetMinX(self.progressView.frame);
    CGFloat labelY = CGRectGetMaxY(self.progressView.frame) + padding;
    self.downloadPercentLabel.frame = CGRectMake(labelX, labelY, labelW * 0.5, labelH);
    
    // 视频时长label frame
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.downloadPercentLabel.frame), CGRectGetMinY(self.downloadPercentLabel.frame), labelW, labelH);
    
    // 总大小和已经下载大小frame
    self.downloadSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.durationLabel.frame), CGRectGetMinY(self.durationLabel.frame), labelW + labelW * 0.5, labelH);
    
    // 下载/播放按钮frame
    CGFloat downloadBtnH = downloadBtnW;
    CGFloat downloadBtnX = CGRectGetWidth(self.bgView.frame) - downloadBtnW - padding * 2.0;
    CGFloat downloadBtnY = (CGRectGetHeight(self.bgView.frame) - downloadBtnH) * 0.5;
    self.downloadBtn.frame = CGRectMake(downloadBtnX, downloadBtnY, downloadBtnW, downloadBtnH);
}

/**
 * 下载按钮点击
 */
- (void)downloadClick
{
    switch (self.model.downloadStatus) {
        case fileDownloadStatusUnDwonload:
            // 未下载 点击开始下载
            if (self.downloadStartBlock) {
                self.downloadStartBlock();
            }
            break;
        case fileDownloadStatusDownloading:
            // 正在下载 点击暂停下载
            if (self.downloadPauseBlock) {
                self.downloadPauseBlock();
            }
            break;
        case fileDownloadStatusPause:
            // 暂停下载 点击继续下载
            if (self.downloadResumeBlock) {
                self.downloadResumeBlock();
            }
            break;
        case fileDownloadStatusDownloaded:
            // 已经下载完成 点击播放
            if (self.playBlock) {
                self.playBlock();
            }
            break;
            
        default:
            break;
    }
}

// 绑定数据
- (void)setModel:(HYDownloadFileModel *)model
{
    _model = model;
    __weak typeof(HYDownloadFileModel *) weakModel = model;
    
    // 标题
    if (model.remoteName) {
        self.titleLabel.text = model.remoteName;
    }else {
        self.titleLabel.text = model.name;
    }
    [self updateFrames];
    
    // 时长
    self.durationLabel.text = model.totalDuration;
    model.getDurationComplete = ^(NSString * _Nonnull duration) {
        self.durationLabel.text = duration;
    };
    
    // 文件大小
    self.downloadSizeLabel.text = [NSString stringWithFormat:@"%@/%@",model.downloadSizeFormate,model.totalSizeFormate];
    model.getTotalSizeComplete = ^(NSString * _Nonnull size) {
        self.downloadSizeLabel.text = [NSString stringWithFormat:@"%@/%@",weakModel.downloadSizeFormate,size];
    };
    
    // 更新下载进度
    if (model.downloadProgress > 0) {
        NSString *percent = [NSString stringWithFormat:@"%.f%%",model.downloadProgress * 100.0];
        self.downloadPercentLabel.text = percent;
    }
    self.progressView.progress = model.downloadProgress;
    // 根据进度设置进度条和背景色
    UIColor *progressColor = [UIColor colorWithProgress:model.downloadProgress fromColor:[UIColor redColor] toColor:ColorMain];
    self.bgView.backgroundColor = progressColor;
    
    // 根据下载状态更新界面
    switch (model.downloadStatus) {
        case fileDownloadStatusUnDwonload:
            // 未下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            self.downloadPercentLabel.text = @"未下载";
            break;
        case fileDownloadStatusDownloading:
            // 正在下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload.png"] forState:UIControlStateNormal];
            break;
        case fileDownloadStatusPause:
            // 暂停下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            self.downloadPercentLabel.text = @"已暂停";
            break;
        case fileDownloadStatusDownloaded:
            // 下载完成
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            self.downloadPercentLabel.text = @"已下载";
            break;
        default:
            break;
    }
}

@end
