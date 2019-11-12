//
//  HYM3u8DownloadCell.m
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYM3u8DownloadCell.h"

@interface HYM3u8DownloadCell ()

// 标题
@property (nonatomic, weak) UILabel *titleLabel;

// 进度条
@property (nonatomic, weak) UIProgressView *progressView;

// 下载状态
@property (nonatomic, weak) UILabel *downloadStatusLabel;

// 下载按钮
 @property (nonatomic, weak) UIButton *downloadBtn;

// 下载百分比显示
@property (nonatomic, weak) UILabel *downloadPersentLabel;

@end

@implementation HYM3u8DownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubviews];
    }
    
    return self;
}

/**
 * 添加子视图
 */
- (void)createSubviews
{
    // 创建背景视图
    CGFloat padding = 10.0;
    CGFloat bgViewY = 4.0;
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(padding * 0.5, bgViewY, ScWidth - padding, 100 - bgViewY * 2.0)];
    bgView.backgroundColor = ColorMain;
    bgView.layer.cornerRadius = 8.0;
    [self.contentView addSubview:bgView];
    
    // 下载按钮
    CGFloat btnW = 30.0;
    CGFloat btnH = btnW;
    CGFloat btnX = CGRectGetWidth(bgView.frame) - btnW - padding * 0.5;
    CGFloat btnY = (CGRectGetHeight(bgView.frame) - btnH) * 0.5;
    CGFloat safeW = btnX;
    UIButton *downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
    [downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadClick) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:downloadBtn];
    self.downloadBtn = downloadBtn;
    
    // 下载进度条
    UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(padding, 0, safeW - padding * 2.0, 0)];
    CGFloat progressY = btnY + (btnH - CGRectGetHeight(progressView.frame)) * 0.5;
    CGRect frame = progressView.frame;
    frame.origin.y = progressY;
    progressView.frame = frame;
    progressView.trackTintColor = [UIColor whiteColor];
    [bgView addSubview:progressView];
    self.progressView = progressView;
    
    // 标题
    CGFloat titleH = 20.0;
    CGFloat titleY = CGRectGetMinY(progressView.frame) - titleH - padding;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, titleY, safeW - padding, titleH)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.text = @"http://www.baidu.com";
    [bgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // 下载百分比显示
    CGFloat persentW = 60.0;
    CGFloat persentH = CGRectGetHeight(titleLabel.frame);
    CGFloat persentX = safeW - persentW;
    CGFloat persentY = CGRectGetMaxY(progressView.frame) + padding;
    UILabel *downloadPersentLabel = [[UILabel alloc]initWithFrame:CGRectMake(persentX, persentY, persentW, persentH)];
    downloadPersentLabel.textColor = [UIColor whiteColor];
    downloadPersentLabel.font = [UIFont systemFontOfSize:14.0];
    downloadPersentLabel.textAlignment = NSTextAlignmentRight;
    [bgView addSubview:downloadPersentLabel];
    self.downloadPersentLabel = downloadPersentLabel;
    
    // 下载状态
    UILabel *downloadStatusLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, persentY, safeW - persentW - padding, persentH)];
    downloadStatusLabel.textColor = [UIColor whiteColor];
    downloadStatusLabel.font = [UIFont systemFontOfSize:14.0];
    downloadStatusLabel.text = @"未下载";
    [bgView addSubview:downloadStatusLabel];
    self.downloadStatusLabel = downloadStatusLabel;
}

#pragma mark - setter
/**
 * 绑定数据模型
 */
- (void)setModel:(HYM3u8FileModel *)model
{
    _model = model;
    
    // 下载地址/文件名字
    self.titleLabel.text = model.fileName.length > 0 ? model.fileName : model.downloadUrl;
    
    // 更新进度条
    self.progressView.progress = model.progress;
    self.downloadPersentLabel.text = [NSString stringWithFormat:@"%.f%%",model.progress * 100.0];
    
    // 根据下载状态更新界面
    switch (model.status) {
        case downloadStatusUndownload:
            // 未下载
            self.downloadStatusLabel.text = @"未下载";
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
            break;
        case downloadStatusGettingFrames:
            // 获取分片信息中
            self.downloadStatusLabel.text = @"正在获取分片信息...";
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
            break;
        case downloadStatusDownloadingFrame:
            // 下载分片中
            self.downloadStatusLabel.text = [NSString stringWithFormat:@"共%lu个分片,正在下载第%d个分片...",(unsigned long)model.tsListsArray.count,model.downloadFrameIndex];
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
            break;
        case downloadStatusMergeFrames:
            // 合并分片中
            self.downloadStatusLabel.text = @"正在合并分片...";
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
            break;
        case downloadStatusConverting:
            // 分片合并完成 视频转换中
            self.downloadStatusLabel.text = @"正在转换视频...";
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
            break;
        case downloadStatusComplete:
            // 下载完成
            self.downloadStatusLabel.text = @"已下载";
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"complete"] forState:UIControlStateNormal];
            break;
        case downloadStatusError:
            // 下载出错
            self.downloadStatusLabel.text = [NSString stringWithFormat:@"下载失败:%@",model.errorMessage];
            [self.downloadBtn setBackgroundImage:[UIImage imageNamed:@"error"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

#pragma mark - action
/**
 * 下载按钮点击
 */
- (void)downloadClick
{
    switch (self.model.status) {
        case downloadStatusUndownload:
            // 未下载 点击开始下载
            if (self.startDownloadBlock) {
                self.startDownloadBlock(self.model);
            }
            break;
            
        default:
            break;
    }
}

@end
