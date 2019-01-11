//
//  HYURLConnectionUtil.h
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYURLConnectionUtil : NSObject

/**
 * 异步GET请求
 * urlString 请求地址
 * headers 头部信息
 * parameters 参数
 * success 成功回调
 * faile 失败回调
 */
+ (void)GET:(NSString *)urlString
    headers:(nullable NSDictionary *)headers
 parameters:(nullable NSDictionary *)parameters
   complete:(nullable void (^)(void))complete
    success:(nullable void (^)(NSData *result,NSURLResponse *response))success
      faile:(nullable void (^)(NSURLResponse *response,NSData *result,NSError *error))faile;

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
       faile:(nullable void (^)(NSURLResponse *response,NSData *result,NSError *error))faile;

/**
 * 同步GET请求
 * urlString 请求地址
 * headers 请求头信息
 * parameters 请求参数
 */
+ (NSData *)syncGET:(NSString *)urlString
           headers:(nullable NSDictionary *)headers
        parameters:(nullable NSDictionary *)parameters;

/**
 * 异步POST请求
 * urlString 请求地址
 * headers 请求头部信息
 * parameters 请求参数
 */
+ (NSData *)syncPOST:(NSString *)urlString
            headers:(nullable NSDictionary *)headers
         parameters:(nullable NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
