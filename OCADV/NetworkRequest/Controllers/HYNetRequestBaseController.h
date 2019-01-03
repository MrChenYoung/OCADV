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

// 结果展示
@property (nonatomic, copy) NSString *requestResult;

// 同步GET请求点击回调
@property (nonatomic, copy) void (^syncGetRequestBlock)(NSString *phoneNumber);

// 同步POST请求点击回调
@property (nonatomic, copy) void (^syncPostRequestBlock)(NSString *phoneNumber);

// 异步GET请求点击回调
@property (nonatomic, copy) void (^asyncGetRequestBlock)(NSString *phoneNumber);

// 异步POST请求点击回调
@property (nonatomic, copy) void (^asyncPostRequestBlock)(NSString *phoneNumber);

// 开始下载回调
@property (nonatomic, copy) void (^downloadStartBlock)(NSString *downloadUrl,NSString *savePath);

// 暂定下载回调
@property (nonatomic, copy) void (^downloadPauseBlock)(NSString *url);

// 继续下载回调
@property (nonatomic, copy) void (^downloadResumeBlock)(NSString *url);

// 播放回调
@property (nonatomic, copy) void (^playBlock)(void);

// 下载进度
@property (nonatomic, assign) double downloadProgress;

// 下载状态改变
@property (nonatomic, assign) fileState downloadState;

// 设置下载文件名
@property (nonatomic, copy) NSString *downloadFileName;

// 更新下载文件总大小
@property (nonatomic, assign) long long downloadFileTotalSize;

// 更新下载文件已经下载的大小
@property (nonatomic, assign) long long downloadFileSaveSize;

/**
 * 通过读取本地下载的文件的大小更新下载界面
 */
- (void)updateDownloadUI;

@end

NS_ASSUME_NONNULL_END
