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
@property (nonatomic, copy, readwrite) NSString *totalSizeFormate;
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
    }
    
    return self;
}

+ (instancetype)downloadFileWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}

/**
 * 格式化文件总大小
 */
- (void)setTotalLength:(long long)totalLength
{
    _totalLength = totalLength;
    
    if (totalLength == 0) {
        self.totalSizeFormate = @"0MB";
    }else {
        NSString *totalLengthFormater = [NSByteCountFormatter stringFromByteCount:totalLength countStyle:NSByteCountFormatterCountStyleFile];
        self.totalSizeFormate = totalLengthFormater;
    }
}

/**
 * 格式化下载大小
 */
- (void)setDownloadLength:(long long)downloadLength
{
    _downloadLength = downloadLength;
    
    if (downloadLength == 0) {
        self.downloadSizeFormate = @"0MB";
    }else {
        NSString *downloadLengthFormater = [NSByteCountFormatter stringFromByteCount:downloadLength countStyle:NSByteCountFormatterCountStyleFile];
        self.downloadSizeFormate = downloadLengthFormater;
    }
}

/**
 * 获取时长
 */
- (void)getDuration
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.downloadUrl];
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:[NSNumber numberWithBool:NO]};
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:options];
        int seconds = ceil(asset.duration.value/asset.duration.timescale);
        NSString *result = [NSString stringWithFormat:@"%ds",seconds];
        self.totalDuration = result;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.getDurationComplete) {
                self.getDurationComplete(result);
            }
        });
    });
}

/**
 * 获取文件大小
 */
- (void)getFileSize
{
    NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
    [mURLRequest setHTTPMethod:@"HEAD"];
    mURLRequest.timeoutInterval = 5.0;
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:mURLRequest queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (!connectionError) {
            [self getFileSizeSuccess:response];
        }else {
            [self getFileSizeFail];
        }
    }];
}

/**
 * 获取文件大小成功处理
 */
- (void)getFileSizeSuccess:(NSURLResponse *)response
{
    NSDictionary *dict = [(NSHTTPURLResponse *)response allHeaderFields];
    NSNumber *length = [dict objectForKey:@"Content-Length"];
    
    self.totalLength = length.longLongValue;
    
    // 获取文件大小成功 格式化成字符串
    NSString *result = [NSByteCountFormatter stringFromByteCount:length.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
    
    self.totalSizeFormate = result;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTotalSizeComplete) {
            self.getTotalSizeComplete(result);
        }
    });
}

/**
 * 获取文件大小成功处理
 */
- (void)getFileSizeFail
{
    // 获取文件大小失败
    self.totalSizeFormate = @"0MB";
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.getTotalSizeComplete) {
            self.getTotalSizeComplete(@"0MB");
        }
    });
}

@end
