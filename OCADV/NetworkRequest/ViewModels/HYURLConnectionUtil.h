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

/**
 * 获取单利
 */
+ (instancetype)share;

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
               faile:(void (^)(NSError *error))faile;

/**
 * 暂停下载
 * urlString下载url
 * return 如果在当前下载列表中找到了正在下载的任务暂停，返回YES 如果没有找到，返回NO
 */
- (BOOL)downloadPause:(NSString *)urlString;

/**
 * 继续暂停的下载任务
 * urlString 下载路径
 * return 如果在当前下载列表中找到了正在下载的任务暂停，返回YES 如果没有找到，返回NO
 */
- (BOOL)downloadResume:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
