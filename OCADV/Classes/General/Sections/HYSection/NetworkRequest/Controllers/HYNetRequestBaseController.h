//
//  HYNetRequestBaseController.h
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYNetRequestBaseController : UIViewController

#pragma mark - GET POST请求基本使用
// 同步GET请求点击回调
@property (nonatomic, copy) void (^syncGetRequestBlock)(NSString *phoneNumber);

// 同步POST请求点击回调
@property (nonatomic, copy) void (^syncPostRequestBlock)(NSString *phoneNumber);

// 异步GET请求点击回调
@property (nonatomic, copy) void (^asyncGetRequestBlock)(NSString *phoneNumber);

// 异步POST请求点击回调
@property (nonatomic, copy) void (^asyncPostRequestBlock)(NSString *phoneNumber);

/**
 * 手机号归属地请求结果处理
 */
- (void)phoneNumberLocationAnalysis:(NSString *)result;

#pragma mark - 下载文件
// 下载文件model
@property (nonatomic, weak) HYDownloadFileModel *downloadFileModel;

// 开始下载回调
@property (nonatomic, copy) void (^downloadStartBlock)(HYDownloadFileModel *model);

// 暂定下载回调
@property (nonatomic, copy) void (^downloadPauseBlock)(HYDownloadFileModel *model);

// 继续下载回调
@property (nonatomic, copy) void (^downloadResumeBlock)(HYDownloadFileModel *model);

// 播放回调
@property (nonatomic, copy) void (^playBlock)(void);

// m3u8视频下载回调
@property (nonatomic, copy) void (^toM3u8DownloadControllerBlock)(void);

#pragma mark - 图片上传
// 更新后的imageModel
@property (nonatomic, weak) HYUploadImageModel *uploadImageModel;

// 刷新accessToken回调
@property (nonatomic, copy) void (^requestAccessTokenBlock)(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void));

// 上传图片到服务器回调
@property (nonatomic, copy) void (^uploadImageBlock)(NSString *urlString,NSDictionary *parameters,NSData *imageData,void (^success)(NSString *response), void (^faile)(void), void (^progress)(double progress),void (^finish)(NSString *responseContent));

// 获取素材列表
@property (nonatomic, copy) void (^loadImageListBlock)(NSString *urlString,NSDictionary *parameters,void (^requestSuccess)(NSData *));

/**
 * 压缩要上传的图片 压缩到500kb
 */
- (void)compressImageComplete:(void (^)(void))complete;

@end

NS_ASSUME_NONNULL_END
