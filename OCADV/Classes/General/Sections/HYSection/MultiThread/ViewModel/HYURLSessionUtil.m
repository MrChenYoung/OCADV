//
//  HYURLSessionUtil.m
//  Test4iOS
//
//  Created by MrChen on 2018/12/20.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYURLSessionUtil.h"
#import "NSURLSession+CorrectedResumeData.h"
#import <UIKit/UIKit.h>

// 下载任务的标识key
#define DOWNLOADTASKDESCROPTIONKEY @"downloadTaskDescription"
// 下载任务存储路径的key
#define DOWNLOADSAVEPATHKEY @"downloadSavePath"

@interface HYURLSessionUtil ()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

// session
@property (nonatomic, strong) NSURLSession *urlSession;

// 所有已经开启的下载任务
@property (nonatomic, strong) NSMutableArray *downloadTasks;

@end


@implementation HYURLSessionUtil

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化URLSession
        [self initUrlSession];
    }
    return self;
}

/**
 * 初始化URLSession
 */
- (void)initUrlSession
{
    self.downloadTasks = [NSMutableArray array];
    
    // 单线程代理队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount = 1;
    
    // 允许后台下载
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"sessionBackgroundDownload"];
    // 允许蜂窝网络下载，默认为YES，
    config.allowsCellularAccess = YES;
    
    self.urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
}

/**
 * 开始下载文件资源
 */
- (void)downloadWithUrl:(NSString *)url savePath:(NSString *)savePath
{
    [self downloadWithUrl:url resumeData:nil savePath:savePath];
}


/**
 * 继续下载文件资源(如果data传nil从头开始下载)
 */
- (void)downloadWithUrl:(NSString *)url resumeData:(NSData *)data savePath:(NSString *)savePath
{
    if (url.length == 0 || url == nil) return;
    if (savePath.length == 0 || savePath == nil) return;
    
    NSURLSessionTask *downloadTask = nil;
    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (data) {
        // 继续下载(断点续传)
        if (version >= 10.0 && version < 10.2) {
            downloadTask = [self.urlSession downloadTaskWithCorrectResumeData:data];
        }else {
           downloadTask = [self.urlSession downloadTaskWithResumeData:data];
        }
    }else {
        // 从头下载
        downloadTask = [self.urlSession downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
    
    // 设置任务标识
    downloadTask.taskDescription = url;
    NSDictionary *dic = @{DOWNLOADTASKDESCROPTIONKEY:url,DOWNLOADSAVEPATHKEY:savePath};
    [self.downloadTasks addObject:dic];
    
    // 开始下载(继续下载)
    [downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate
// 正在下载 接收到服务器返回数据，会被调用多次
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *totalLength = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleFile];
    NSString *downloadLength = [NSByteCountFormatter stringFromByteCount:totalBytesWritten countStyle:NSByteCountFormatterCountStyleFile];
    CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSLog(@"正在下载,总大小:%@,已下载:%@ %.2f%%",totalLength,downloadLength,progress * 100.0);
}

// 开始继续下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"开始继续下载");
}

// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"下载完成:%@",location.path);
    
    NSString *savePath = nil;
    for (NSDictionary *dic in self.downloadTasks) {
        if ([dic[DOWNLOADTASKDESCROPTIONKEY] isEqualToString:downloadTask.taskDescription]) {
            savePath = dic[DOWNLOADSAVEPATHKEY];
            break;
        }
    }
    if (savePath == nil) {
        NSLog(@"未找到存储路径");
        return;
    }

    // 下载完成 移动文件到指定的路径下 原路径文件由系统自动删除
    NSError *err = nil;
    [[NSFileManager defaultManager] moveItemAtPath:[location path] toPath:savePath error:&err];
    if (err) {
        NSLog(@"下载完成,移动失败:%@",err);
    }else {
        NSLog(@"下载完成,移动成功:%@",savePath);
    }
}

@end
