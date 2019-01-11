//
//  HYURLConnectionUtil.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYURLConnectionUtil.h"

@interface HYURLConnectionUtil ()

@end

@implementation HYURLConnectionUtil

/**
 * 异步GET请求
 * urlString 请求地址
 * headers 头部信息
 * parameters 参数
 * complete 请求完成(包含请求成功和请求失败)
 * success 成功回调
 * faile 失败回调
 */
+ (void)GET:(NSString *)urlString
    headers:(nullable NSDictionary *)headers
 parameters:(nullable NSDictionary *)parameters
   complete:(nullable void (^)(void))complete
    success:(nullable void (^)(NSData *result,NSURLResponse *response))success
      faile:(nullable void (^)(NSURLResponse *response,NSData *result,NSError *error))faile
{
    NSURLRequest *request = [self creatGetRequest:urlString headers:headers parameters:parameters];
    
    // 发送异步请求
    [self sendAsynchronousRequest:request complete:complete success:success faile:faile];
}

/**
 * 异步POST请求
 * urlString 请求地址
 * headers 头部信息
 * parameters 参数
 * complete 请求完成(包含请求成功和请求失败)
 * success 成功回调
 * faile 失败回调
 */
+ (void)POST:(NSString *)urlString
    headers:(nullable NSDictionary *)headers
 parameters:(nullable NSDictionary *)parameters
   complete:(nullable void (^)(void))complete
    success:(nullable void (^)(NSData *result,NSURLResponse *response))success
      faile:(nullable void (^)(NSURLResponse *response,NSData *result,NSError *error))faile
{
    // 创建request对象
    NSURLRequest *request = [self createPostRequest:urlString headers:headers parameters:parameters];
    
    // 发送异步请求
    [self sendAsynchronousRequest:request complete:complete success:success faile:faile];
}

/**
 * 同步GET请求
 * urlString 请求地址
 * headers 请求头信息
 * parameters 请求参数
 */
+ (NSData *)syncGET:(NSString *)urlString
       headers:(nullable NSDictionary *)headers
    parameters:(nullable NSDictionary *)parameters
{
    // 创建request对象
    NSURLRequest *request = [self creatGetRequest:urlString headers:headers parameters:parameters];
    
    // 发送同步请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return data;
}

/**
 * 异步POST请求
 * urlString 请求地址
 * headers 请求头部信息
 * parameters 请求参数
 */
+ (NSData *)syncPOST:(NSString *)urlString
            headers:(nullable NSDictionary *)headers
         parameters:(nullable NSDictionary *)parameters
{
    // 创建request对象
    NSURLRequest *request = [self createPostRequest:urlString headers:headers parameters:parameters];
    
    // 发送同步请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return data;
}

/**
 * 创建GET请求request对象
 * urlString 请求地址
 * headers 请求头部信息
 * parameters 请求参数
 */
+ (NSURLRequest *)creatGetRequest:(NSString *)urlString
                                 headers:(NSDictionary *)headers
                              parameters:(NSDictionary *)parameters
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?",urlString];
    
    // 拼接参数
    for (NSString *key in parameters) {
        urlStr = [urlStr stringByAppendingFormat:@"%@=%@&",key,parameters[key]];
    }
    
    // 创建url对象
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // 创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    // 超时时间默认10秒
    request.timeoutInterval = 10.0;
    
    // 添加头部信息
    [request setAllHTTPHeaderFields:headers];
    
    return request;
}

/**
 * 创建POST请求request对象
 * urlString 请求地址
 * headers 请求头部
 * parameters 请求参数
 */
+ (NSURLRequest *)createPostRequest:(NSString *)urlString
                            headers:(NSDictionary *)headers
                         parameters:(NSDictionary *)parameters
{
    // 创建url对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 创建请求对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    // POST请求
    request.HTTPMethod = @"POST";
    
    // 超时时间默认10秒
    request.timeoutInterval = 10.0;
    
    // 添加头部信息
    [request setAllHTTPHeaderFields:headers];
    
    // 设置参数
    NSString *par = @"";
    for (NSString *key in parameters) {
        par = [par stringByAppendingFormat:@"%@=%@&",key,parameters[key]];
    }
    request.HTTPBody = [par dataUsingEncoding:NSUTF8StringEncoding];
    
    return request;
}


/**
 * 发送异步请求
 */
+ (void)sendAsynchronousRequest:(NSURLRequest *)request
                       complete:(void (^)(void))complete
                        success:(nullable void (^)(NSData *result,NSURLResponse *response))success
                          faile:(nullable void (^)(NSURLResponse *response,NSData *result,NSError *error))faile
{
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        // 获取返回信息编码方式
        NSLog(@"编码方式:%@",response.textEncodingName);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
            
            if (connectionError) {
                // 请求失败
                if (faile) {
                    faile(response,data,connectionError);
                }
            }else {
                // 请求成功
                if (success) {
                    success(data,response);
                }
            }
        });
    }];
}

@end
