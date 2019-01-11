//
//  HYURLConnectionUpload.m
//  OCADV
//
//  Created by MrChen on 2019/1/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYURLConnectionUpload.h"

#define KUploadFileConnectionKey @"uploadFileConnection"
#define KUploadFileResultkey @"uploadFileResultkey"
#define KUploadFileRequestStatusCodeKey @"uploadFileRequestStatusCodeKey"
#define KUploadFileRequestSuccessKey @"uploadFileRequestSuccessKey"
#define KUploadFileRequestFaileKey @"uploadFileRequestFaileKey"
#define KUploadFileProgressChangedKey @"uploadFileProgressChanged"
#define KUploadFileFinishKey @"uploadFileFinishKey"

@interface HYURLConnectionUpload()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

// 上传任务列表
@property (nonatomic, strong) NSMutableDictionary *uploadTasks;

@end

@implementation HYURLConnectionUpload

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYURLConnectionUpload *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super allocWithZone:zone];
        singleTon.uploadTasks = [NSMutableDictionary dictionary];
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
 * 上传文件
 * urlString 上传url
 * paramName 服务器字段名
 * fileName文件名
 * fileContentType 上传文件类型(默认为image/png,图片类型)
 * header 请求头信息
 * fileData 上传文件的二进制数据
 * success 请求成功回调
 * faile 请求失败回调
 * progress 上传进度改变回调
 * finish 上传完成回调
 */
- (void)uploadFile:(NSString *)urlString
         paramName:(NSString *)paramName
          fileName:(NSString *)fileName
       contentType:(NSString *)fileContentType
            header:(NSDictionary *)header
          fileData:(NSData *)fileData
           success:(void (^)(NSString *response))success
             faile:(void (^)(NSError *error, NSString *errorMessage))faile
          progress:(void (^)(CGFloat progress))progressBlock
            finish:(void (^)(void))finish
{
    // 取出当前上传任务信息
    NSDictionary *dic = self.uploadTasks[urlString];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    
    
    // 请求体里的分割符和换行符
    NSString *boundry = @"----WebKitFormBoundaryhBDKBUWBHnAgvz9c";
    NSData *newLine = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    // 请求url
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置请求头
    if (header) {
        for (NSString *key in header) {
            [request setValue:header[key] forHTTPHeaderField:key];
        }
    }
    
    // 设置请求方式为POST
    request.HTTPMethod = @"POST";
    
    // 设置请求头
    NSString *filed = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundry];
    [request setValue:filed forHTTPHeaderField:@"Content-Type"];
    
    // 拼接请求体
    /*
     --分隔符
     Content-Disposition:参数
     Content-Type:参数
     空行
     文件参数
     
     //02.非文件拼接参数
     --分隔符
     Content-Disposition:参数
     空行
     非文件的二进制数据
     
     //03.结尾标识
     --分隔符--
     */
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"--%@",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"",paramName,fileName];
    [body appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    if (fileContentType == nil || fileContentType.length == 0) {
        fileContentType = @"image/png";
    }
    NSString *contentType = [NSString stringWithFormat:@"Content-Type:%@",fileContentType];
    [body appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    [body appendData:newLine];
    [body appendData:newLine];
    
    // 拼接文件内容
    [body appendData:fileData];
    [body appendData:newLine];
    
    // 拼接非文件参数
    [body appendData:[[NSString stringWithFormat:@"--%@",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    [body appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    [body appendData:newLine];
    [body appendData:newLine];
    
    // 拼接非文件参数的二进制文件
    [body appendData:[@"abc" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    
    // 结尾标识
    [body appendData:[[NSString stringWithFormat:@"--%@--",boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:newLine];
    
    // 设置请求体
    request.HTTPBody = body;
    
    // 记录进度回调代码块
    if (progressBlock) {
        [dic setValue:progressBlock forKey:KUploadFileProgressChangedKey];
    }
    if (success) {
        [dic setValue:success forKey:KUploadFileRequestSuccessKey];
    }
    if (faile) {
        [dic setValue:faile forKey:KUploadFileRequestFaileKey];
    }
    if (finish) {
        [dic setValue:finish forKey:KUploadFileFinishKey];
    }
    
    // 发送请求
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [dic setValue:connection forKey:KUploadFileConnectionKey];
    
    // 更新任务列表中指定任务信息
    [self.uploadTasks setObject:dic forKey:urlString];
}

#pragma mark - NSURLConnectionDataDelegate
// 收到服务器回复
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary *dic = self.uploadTasks[connection.currentRequest.URL.absoluteString];

    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    NSInteger statusCode = res.statusCode;
    if (statusCode != 200) {
        // 请求失败 添加标记
        [dic setValue:[NSNumber numberWithBool:NO] forKey:KUploadFileResultkey];
    }else {
        // 请求成功
        [dic setValue:[NSNumber numberWithBool:YES] forKey:KUploadFileResultkey];
        [dic setValue:[NSNumber numberWithInteger:statusCode] forKey:KUploadFileRequestStatusCodeKey];
    }
    
    [self.uploadTasks setObject:dic forKey:connection.currentRequest.URL.absoluteString];
}

// 接收到服务器数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 根据添加的标记识别是否请求成功
    NSDictionary *dic = self.uploadTasks[connection.currentRequest.URL.absoluteString];
    BOOL requestSuc = [dic[KUploadFileResultkey] boolValue];
    void (^requestSuccess)(NSString *result) = dic[KUploadFileRequestSuccessKey];
    void (^requestFaile)(NSError *error,NSString *errorMessage) = dic[KUploadFileRequestFaileKey];
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

    if (requestSuc) {
        // 请求成功
        if (requestSuccess) {
            requestSuccess(result);
        }
    }else {
        // 请求失败
        NSInteger errorCode = [dic[KUploadFileRequestStatusCodeKey] integerValue];
        NSError *error = [[NSError alloc]initWithDomain:NSMachErrorDomain code:errorCode userInfo:nil];
        if (requestFaile) {
            requestFaile(error,result);
        }
    }
    
    NSLog(@"收到服务器返回数据:%@",result);
}

// 上传中
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    // 计算上传进度
    CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
    
    // 获取进度条更新回调代码块
    NSDictionary *dic = self.uploadTasks[connection.currentRequest.URL.absoluteString];
    void (^progressBlock)(CGFloat progress)  = dic[KUploadFileProgressChangedKey];
    
    // 更新进度条
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progressBlock) {
            progressBlock(progress);
        }
    });
    
    NSLog(@"上传中:%f",progress);
}

// 上传完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dic = self.uploadTasks[connection.currentRequest.URL.absoluteString];
    void (^finish)(void) = dic[KUploadFileFinishKey];
    
    BOOL requestSuc = [dic[KUploadFileResultkey] boolValue];
    if (!requestSuc) return;
    
    // 上传完成回调
    dispatch_async(dispatch_get_main_queue(), ^{
        if (finish) {
            finish();
        }
    });
    
    NSLog(@"上传完成");
}

#pragma mark - NSURLConnectionDelegate
// 上传失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSDictionary *dic = self.uploadTasks[connection.currentRequest.URL.absoluteString];
    void (^requestFaile)(NSError *error,NSString *errorMessage) = dic[KUploadFileRequestFaileKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (requestFaile) {
            requestFaile(error,nil);
        }
    });
}

@end
