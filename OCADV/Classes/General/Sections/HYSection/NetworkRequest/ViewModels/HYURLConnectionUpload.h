//
//  HYURLConnectionUpload.h
//  OCADV
//
//  Created by MrChen on 2019/1/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HYURLConnectionUpload : NSObject

/**
 * 获取单利
 */
+ (instancetype)share;

/**
 * 上传文件
 * urlString 上传url
 * paramName 服务器字段名
 * fileName文件名
 * fileContentType 上传文件类型(默认为image/png,图片类型)
 * header 请求头信息
 * params 上传需要的额外参数
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
            params:(NSDictionary *)params
          fileData:(NSData *)fileData
           success:(void (^)(NSString *response))success
             faile:(void (^)(NSError *error, NSString *errorMessage))faile
          progress:(void (^)(CGFloat progress))progressBlock
            finish:(void (^)(NSString *responseContent))finish;

@end
