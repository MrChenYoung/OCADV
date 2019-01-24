//
//  HYURLConnectionDownload.m
//  OCADV
//
//  Created by MrChen on 2019/1/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYURLConnectionDownload.h"

#define DownloadConnectionKey @"DownloadConnection"
#define DidReceiveResponseKey @"DidReceiveResponse"
#define DownloadRequestSuccessKey @"DownloadRequestSuccess"
#define DownloadFileSavePathKey @"DownloadFileSavePath"
#define DownloadProgressKey @"DownloadProgress"
#define DownloadFileHandleKey @"DownloadFileHandle"
#define DownloadFileTotalLengthKey @"DownloadFileTotalLength"
#define DownloadFileSavedLengthKey @"DownloadFileSavedLength"
#define DownloadFileFaileKey @"DownloadFileFaile"
#define DownloadFileCompleteKey @"DownloadFileComplete"

typedef void (^didReceiveResponseBlock)(long long totalSize,NSString *fileName);
typedef void (^downloadProgressBlock)(double progress,long long downloadLength);
typedef void (^downloadFaileBlock)(NSError *error);
typedef void (^downloadCompleteBlock)(void);

@interface HYURLConnectionDownload ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

// 下载获取到响应
@property (nonatomic, copy) void (^downloadReceiveResponse)(long long totalSize,NSString *fileName);

// 下载任务列表
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

@end

@implementation HYURLConnectionDownload

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYURLConnectionDownload *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super allocWithZone:zone];
        singleTon.downloadTasks = [NSMutableDictionary dictionary];
    });
    
    return singleTon;
}

/**
 * 获取单利
 */
+ (instancetype)share
{
    return [[self alloc]init];
}


/**
 * 下载文件(如果指定路径下的文件已经已经存在会自动断点续传下载)
 * urlString 下载路径
 * savePath 下载文件保存的路径
 * didReceiveResponse 收到服务器返回的文件基本信息回调
 * progressChanged 下载进度改变回调
 * complete 下载完成回调
 * faile 下载失败回调
 */
- (void)downloadFile:(NSString *)urlString
            savePath:(NSString *)savePath
  didReceiveResponse:(void (^)(long long totalSize,NSString *fileName))didReceiveResponse
     progressChanged:(void (^)(double progress,long long downloadLength))progressChanged
            complete:(void (^)(void))complete
               faile:(void (^)(NSError *error))faile
{
    // 保存下载任务信息
    NSMutableDictionary *dicM = self.downloadTasks[urlString];
    if (dicM == nil) {
        dicM = [NSMutableDictionary dictionary];
    }
    
    if (didReceiveResponse) {
        [dicM setObject:didReceiveResponse forKey:DidReceiveResponseKey];
    }
    
    if (savePath) {
        [dicM setObject:savePath forKey:DownloadFileSavePathKey];
    }
    
    if (progressChanged) {
        [dicM setObject:progressChanged forKey:DownloadProgressKey];
    }
    
    if (complete) {
        [dicM setObject:complete forKey:DownloadFileCompleteKey];
    }
    
    if (faile) {
        [dicM setObject:faile forKey:DownloadFileFaileKey];
    }
    
    
    // 创建url对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 创建request对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置从上次下载的位置下载
    long long lastDownloadPoint = [self getLastDownloadPoint:urlString savePath:savePath];
    [dicM setObject:[NSNumber numberWithLongLong:lastDownloadPoint] forKey:DownloadFileSavedLengthKey];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",lastDownloadPoint] forHTTPHeaderField:@"Range"];
    
    // 发送异步请求
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) {
        [dicM setObject:connection forKey:DownloadConnectionKey];
    }
    
    [self.downloadTasks setObject:dicM forKey:urlString];
}


/**
 * 暂停下载
 * urlString下载url
 * return 如果在当前下载列表中找到了正在下载的任务暂停，返回YES 如果没有找到，返回NO
 */
- (BOOL)downloadPause:(NSString *)urlString
{
    NSMutableDictionary *dicM = self.downloadTasks[urlString];
    if (dicM) {
        NSURLConnection *connection = dicM[DownloadConnectionKey];
        if (connection) {
            // 取消下载
            [connection cancel];
            connection = nil;
            
            // 移除保存的connection
            [dicM removeObjectForKey:DownloadConnectionKey];
            [self.downloadTasks setObject:dicM forKey:urlString];
            
            return YES;
        }
    }
    
    return NO;
}

/**
 * 继续暂停的下载任务
 * urlString 下载路径
 * return 如果在当前下载列表中找到了正在下载的任务暂停，返回YES 如果没有找到，返回NO
 */
- (BOOL)downloadResume:(NSString *)urlString
{
    NSMutableDictionary *dicM = self.downloadTasks[urlString];
    if (dicM) {
        [self downloadFile:urlString savePath:dicM[DownloadFileSavePathKey] didReceiveResponse:dicM[DidReceiveResponseKey] progressChanged:dicM[DownloadProgressKey] complete:dicM[DownloadFileCompleteKey] faile:dicM[DownloadFileFaileKey]];
        return YES;
    }else {
        return NO;
    }
}

/**
 * 获取最后下载的位置
 * urlString 下载路径
 * savePath 文件保存的路径
 * return 如果返回0表示没有下载
 */
- (long long)getLastDownloadPoint:(NSString *)urlString savePath:(NSString *)savePath
{
    long long lastPoint = 0;
    
    // 先从当前的下载任务列表中查询
    NSMutableDictionary *dicM = self.downloadTasks[urlString];
    lastPoint = [dicM[DownloadFileSavedLengthKey] longLongValue];
    
    // 如果从下载任务列表中没有查询到，根据保存路径从磁盘查找
    if (lastPoint == 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:savePath]) {
            // 文件存在
            lastPoint = [[fileManager attributesOfItemAtPath:savePath error:nil] fileSize];
        }else {
            // 文件不存在
            lastPoint = 0;
        }
    }
    
    return lastPoint;
}

#pragma mark - NSURLConnectionDataDelegate
// 收到回复
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableDictionary *dicM = [self.downloadTasks objectForKey:connection.currentRequest.URL.absoluteString];
    
    // 根据返回的状态码确定请求是否成功
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    BOOL requestSuccess = NO;
    if (res.statusCode == 200) {
        // 请求下载成功 准备开始下载
        requestSuccess = YES;
    }else if (res.statusCode == 206){
        // 部分下载请求成功 用于断点续传
        requestSuccess = YES;
    }else {
        // 请求失败
        requestSuccess = NO;
    }
    
    [dicM setObject:[NSNumber numberWithBool:requestSuccess] forKey:DownloadRequestSuccessKey];
    
    if (!requestSuccess) {
        [self.downloadTasks setObject:dicM forKey:connection.currentRequest.URL.absoluteString];
        
        downloadFaileBlock downloadFaile = dicM[DownloadFileFaileKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (downloadFaile) {
                downloadFaile([[NSError alloc]initWithDomain:NSURLErrorDomain code:res.statusCode userInfo:nil]);
            }
        });
        return;
    }
    
    // 文件的总大小
    long long totalLength = response.expectedContentLength;
    // 防止断点续传的时候获取的文件总大小不准确
    long long downloadLength = [dicM[DownloadFileSavedLengthKey] longLongValue];
    if (downloadLength > 0) {
        totalLength += downloadLength;
    }
    
    // 文件名字
    NSString *fileName = response.suggestedFilename;
    
    // 保存文件的总大小，用于计算下载进度
    if ([[dicM objectForKey:DownloadFileTotalLengthKey] longLongValue] == 0) {
        [dicM setObject:[NSNumber numberWithLongLong:totalLength] forKey:DownloadFileTotalLengthKey];
    }
    long long lastDownloadPoint = [[dicM objectForKey:DownloadFileSavedLengthKey] longLongValue];
    if (lastDownloadPoint == 0) {
        [dicM setObject:[NSNumber numberWithLongLong:0] forKey:DownloadFileSavedLengthKey];
    }
    
    // 收到下载文件的信息
    didReceiveResponseBlock receiveResponseBlock = dicM[DidReceiveResponseKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (receiveResponseBlock) {
            receiveResponseBlock(totalLength, fileName);
        }
    });
    
    // 根据文件的存储路径创建空文件准备写数据，如果文件已经存在 断点续传
    NSString *savePath = dicM[DownloadFileSavePathKey];
    if (lastDownloadPoint == 0) {
        [[NSFileManager defaultManager] createFileAtPath:savePath contents:nil attributes:nil];
    }
    
    // 创建文件句柄并保存
    if ([dicM objectForKey:DownloadFileHandleKey] == nil) {
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:savePath];
        if (handle) {
            [dicM setObject:handle forKey:DownloadFileHandleKey];
        }
    }
    
    [self.downloadTasks setObject:dicM forKey:connection.currentRequest.URL.absoluteString];
}

// 接收到数据 多次调用
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 写数据到文件
    NSMutableDictionary *dicM = self.downloadTasks[connection.currentRequest.URL.absoluteString];
    
    // 获取请求是否成功
    BOOL success = [dicM[DownloadRequestSuccessKey] boolValue];
    if (!success) {
        // 请求失败
        return;
    }
    
    NSFileHandle *handle = dicM[DownloadFileHandleKey];
    [handle seekToEndOfFile];
    [handle writeData:data];
    
    // 计算下载进度
    long long totalLength = [dicM[DownloadFileTotalLengthKey] longLongValue];
    long long lastSavedLength = [dicM[DownloadFileSavedLengthKey] longLongValue];
    double progress = (double)(lastSavedLength + data.length)/totalLength;
    downloadProgressBlock downloadProgressB = dicM[DownloadProgressKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadProgressB) {
            downloadProgressB(progress,lastSavedLength + data.length);
        }
    });
    
    [dicM setObject:[NSNumber numberWithLongLong:lastSavedLength + data.length] forKey:DownloadFileSavedLengthKey];
    [self.downloadTasks setObject:dicM forKey:connection.currentRequest.URL.absoluteString];
    
    NSString *flag = [connection.originalRequest.URL.absoluteString isEqualToString:connection.currentRequest.URL.absoluteString] ? @"是" : @"否";
//    NSLog(@"下载中:%@",flag);
}

// 下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary *dicM = self.downloadTasks[connection.currentRequest.URL.absoluteString];
    BOOL succcess = [dicM[DownloadRequestSuccessKey] boolValue];
    if (!succcess) {
        return;
    }
    
    downloadCompleteBlock downloadComplete = dicM[DownloadFileCompleteKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadComplete) {
            downloadComplete();
        }
    });
    
    // 移除保存的下载信息
    [self.downloadTasks removeObjectForKey:connection.currentRequest.URL.absoluteString];
}

#pragma mark - NSURLConnectionDelegate
// 下载失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSMutableDictionary *dicM = self.downloadTasks[connection.currentRequest.URL.absoluteString];
    downloadFaileBlock downloadFaile = dicM[DownloadFileFaileKey];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (downloadFaile) {
            downloadFaile(error);
        }
    });
}

@end
