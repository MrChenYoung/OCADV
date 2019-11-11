//
//  HYAFNRequestUtil.m
//  OCADV
//
//  Created by MrChen on 2018/12/26.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYAFNRequestUtil.h"
#import <AFNetworking.h>

@implementation HYAFNRequestUtil

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
    headers:(NSDictionary *)headers
 parameters:(NSDictionary *)parameters
   complete:(nullable void (^)(void))complete
    success:(void (^)(NSString *result))success
      faile:(void (^)(NSString *result,NSError *error))faile
{
    NSString *urlStr = [NSString stringWithFormat:@"%@?",urlString];

    // 拼接参数
    for (NSString *key in parameters) {
        urlStr = [urlStr stringByAppendingFormat:@"%@=%@",key,parameters[key]];
    }
    
    // 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置头部信息
    AFHTTPRequestSerializer *requestSer = [AFHTTPRequestSerializer serializer];
    for (NSString *key in headers) {
        [requestSer setValue:headers[key] forHTTPHeaderField:key];
    }
    manager.requestSerializer = requestSer;
    
    
    // 设置返回数据类型
    AFHTTPResponseSerializer *responseSer = [AFHTTPResponseSerializer serializer];
    responseSer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/json",@"text/javascript",@"application/x-javascript",@"application/javascript", nil];
//    responseSer.acceptableContentTypes = [NSSet setWithObjects:@"application/javascript",nil];
    manager.responseSerializer = responseSer;
    
    // 发送请求
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError *err = nil;
            NSString *result = [responseObject toString];
            
            NSLog(@"成功%@",result);
        }else {
            NSLog(@"错了");
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"失败:%@",task.response);
        NSLog(@"错误:%@",error);
    }];
}

+ (void)POST:(NSString *)url
{
    
}

@end
