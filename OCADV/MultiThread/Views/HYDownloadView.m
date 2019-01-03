//
//  HYDownloadView.m
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYDownloadView.h"

@interface HYDownloadView ()

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
        
        // 默认是未下载状态
        self.state = fileStateUnDwonload;
    }
    return self;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    // 背景视图
    CGFloat padding = 5.0;
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    bgView.backgroundColor = ColorWithRGBA(0.0, 191.0, 255.0, 1.0);
    bgView.layer.cornerRadius = 8;
    [self addSubview:bgView];
    
    // 下载/播放按钮
    CGFloat w = 48.0;
    CGFloat h = w;
    CGFloat x = CGRectGetWidth(bgView.frame) - w - 10.0;
    CGFloat y = (CGRectGetHeight(bgView.frame) - w) * 0.5;
    UIButton *downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(x, y, w, h)];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:downloadBtn];
    self.downloadBtn = downloadBtn;
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding * 2.0, padding * 3.0, CGRectGetMinX(downloadBtn.frame) - padding * 2.0 , 30.0)];
    titleLabel.text = @"";
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [UIColor whiteColor];
    [bgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // 下载进度条
    CGFloat progressX = CGRectGetMinX(titleLabel.frame);
    CGFloat progressY = CGRectGetMaxY(titleLabel.frame) + padding * 2.0;
    CGFloat progressW = CGRectGetMinX(downloadBtn.frame) - progressX - padding * 2.0;
    CGFloat progressH = 30.0;
    UIProgressView *progress = [[UIProgressView alloc]initWithFrame:CGRectMake(progressX, progressY, progressW, progressH)];
    progress.progress = 0.0;
    progress.trackTintColor = [UIColor whiteColor];
    [bgView addSubview:progress];
    self.progressView = progress;
    
    // 下载百分比显示
    CGFloat labelW = CGRectGetWidth(progress.frame) / 3;
    CGFloat labelH = 30.0;
    UILabel *downloadProgressLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(progress.frame), CGRectGetMaxY(progress.frame) + padding, labelW * 0.5, labelH)];
    downloadProgressLabel.textColor = [UIColor whiteColor];
    downloadProgressLabel.font = [UIFont systemFontOfSize:14.0];
    downloadProgressLabel.text = @"未下载";
    [bgView addSubview:downloadProgressLabel];
    self.downloadPercentLabel = downloadProgressLabel;
    
    // 时长
    UILabel *durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(downloadProgressLabel.frame), CGRectGetMinY(downloadProgressLabel.frame), labelW, labelH)];
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.font = [UIFont systemFontOfSize:14.0];
    durationLabel.text = @"0s";
    durationLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:durationLabel];
    self.durationLabel = durationLabel;
    
    // 总大小和已经下载大小
    UILabel *downloadSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(durationLabel.frame), CGRectGetMinY(durationLabel.frame), labelW + labelW * 0.5, labelH)];
    downloadSizeLabel.text = @"0M/0M";
    downloadSizeLabel.textColor = [UIColor whiteColor];
    downloadSizeLabel.font = [UIFont systemFontOfSize:14.0];
    downloadSizeLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:downloadSizeLabel];
    self.downloadSizeLabel = downloadSizeLabel;
}

/**
 * 下载按钮点击
 */
- (void)downloadClick
{
    switch (self.state) {
        case fileStateUnDwonload:
            // 未下载 点击开始下载
            if (self.downloadStartBlock) {
                self.downloadStartBlock();
            }
            break;
        case fileStateDownloading:
            // 正在下载 点击暂停下载
            if (self.downloadPauseBlock) {
                self.downloadPauseBlock();
            }
            break;
        case fileStatePause:
            // 暂停下载 点击继续下载
            if (self.downloadResumeBlock) {
                self.downloadResumeBlock();
            }
            break;
        case fileStateDownloaded:
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
    
    // 标题
    self.titleLabel.text = model.name;
    
    // 时长
    self.durationLabel.text = model.totalDuration;
    model.getDurationComplete = ^(NSString * _Nonnull duration) {
        self.durationLabel.text = duration;
    };
    
    // 文件大小
    NSString *downloadSize = model.downloadSizeFormate == nil ? @"0MB" : model.downloadSizeFormate;
    NSString *totalSize = model.totalSizeFormate == nil ? @"0MB" : model.totalSizeFormate;
    self.downloadSizeLabel.text = [NSString stringWithFormat:@"%@/%@",downloadSize,totalSize];
    model.getTotalSizeComplete = ^(NSString * _Nonnull size) {
        self.downloadSizeLabel.text = [NSString stringWithFormat:@"%@/%@",downloadSize,size];
    };
    
    // 更新下载进度
    if (model.downloadProgress == 0) {
        self.downloadPercentLabel.text = @"未下载";
    }else {
        NSString *percent = [NSString stringWithFormat:@"%.f%%",model.downloadProgress * 100.0];
        self.downloadPercentLabel.text = percent;
    }
    self.progressView.progress = model.downloadProgress;

}

- (void)setState:(fileState)state
{
    _state = state;
    
    switch (state) {
        case fileStateUnDwonload:
            // 未下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            self.downloadPercentLabel.text = @"未下载";
            break;
        case fileStateDownloading:
            // 正在下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload.png"] forState:UIControlStateNormal];
            break;
        case fileStatePause:
            // 暂停下载
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            break;
        case fileStateDownloaded:
            // 下载完成
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
            self.downloadPercentLabel.text = @"已下载";
            break;
        default:
            break;
    }
}

@end
