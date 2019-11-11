//
//  HYDownloadFileModel.m
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYDownloadFileModel.h"
#import <AVFoundation/AVFoundation.h>

@interface HYDownloadFileModel ()
// 文件总大小格式化
@property (nonatomic, copy, readwrite) NSString *totalSizeFormate;

// 已经下载大小格式化
@property (nonatomic, copy, readwrite) NSString *downloadSizeFormate;
@end

@implementation HYDownloadFileModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        // 文件名字
        self.name = dic[@"fileName"];
        
        // 下载路径
        self.downloadUrl = dic[@"url"];
        
        // 总时长
        [self getDuration];
        
        // 总大小
        [self getFileSize];
        
        // 默认视频时长
        self.totalDuration = @"0s";
        
        // 默认下载大小
        self.downloadSizeFormate = @"0KB";
        
        // 默认总大小
        self.totalSizeFormate = @"0KB";
        
        // 更新下载状态
        [self reloadDownloadStatus];
    }
    
    return self;
}

+ (instancetype)downloadFileWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}


#pragma mark - setter
/**
 * 根据名字设置存储路径
 */
- (void)setName:(NSString *)name
{
    _name = name;
    
    // 设置存储路径
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    self.savePath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.name]];
}

/**
 * 格式化文件总大小
 */
- (void)setTotalLength:(long long)totalLength
{
    _totalLength = totalLength;
    
    if (totalLength != 0) {
        NSString *totalLengthFormater = [NSByteCountFormatter stringFromByteCount:totalLength countStyle:NSByteCountFormatterCountStyleFile];
        self.totalSizeFormate = totalLengthFormater;
    }else {
        self.totalSizeFormate = @"0KB";
    }
}

/**
 * 格式化下载大小
 */
- (void)setDownloadLength:(long long)downloadLength
{
    _downloadLength = downloadLength;
    
    if (downloadLength != 0) {
        NSString *downloadLengthFormater = [NSByteCountFormatter stringFromByteCount:downloadLength countStyle:NSByteCountFormatterCountStyleFile];
        self.downloadSizeFormate = downloadLengthFormater;
    }else {
        self.downloadSizeFormate = @"0KB";
    }
}


#pragma mark - custom method
/**
 * 根据本地文件更新下载状态
 */
- (void)reloadDownloadStatus
{
    // 根据下载存储路径从磁盘查询是否已经下载过和已经下载的大小,用于断点续传
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:self.savePath]) {
        long long downloadLength = [[manager attributesOfItemAtPath:self.savePath error:nil] fileSize];
        if (downloadLength > 0) {
            // 文件已经被下载过(下载完成或下载一部分)
            self.downloadProgress = (double)downloadLength/self.totalLength;
            self.downloadLength = downloadLength;
            if (self.downloadProgress == 1) {
                // 已经下载完成
                self.downloadStatus = fileDownloadStatusDownloaded;
            }else {
                // 下载过一部分
                self.downloadStatus = fileDownloadStatusPause;
            }
        }
    }else {
        self.downloadLength = 0;
        self.downloadProgress = 0;
        
        self.downloadStatus = fileDownloadStatusUnDwonload;
    }
}

/**
 * 获取时长
 */
- (void)getDuration
{
    NSURL *url = [NSURL URLWithString:self.downloadUrl];
    [HYAVUtil getVideoDurationWithUrl:url complete:^(double duration) {
        NSString *result = [NSString stringWithFormat:@"%.fs",duration];
        self.totalDuration = result;
        
        if (self.getDurationComplete) {
            self.getDurationComplete(result);
        }
    }];
}

/**
 * 获取文件大小
 */
- (void)getFileSize
{
    NSURL *url = [NSURL URLWithString:self.downloadUrl];
    [HYAVUtil getVideoLengthWithUrl:url complete:^(BOOL success, long long videoLength) {
        if (success) {
            self.totalLength = videoLength;
            
            // 获取文件大小成功 格式化成字符串
            NSString *result = [NSByteCountFormatter stringFromByteCount:videoLength countStyle:NSByteCountFormatterCountStyleFile];
            self.totalSizeFormate = result;
            if (self.getTotalSizeComplete) {
                self.getTotalSizeComplete(result);
            }
        }else {
            [self getFileSizeFail];
        }
    }];
}

/**
 * 获取文件大小成功处理
 */
- (void)getFileSizeFail
{
    // 获取文件大小失败
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTotalSizeComplete) {
            self.getTotalSizeComplete(self.totalSizeFormate);
        }
    });
}

@end
