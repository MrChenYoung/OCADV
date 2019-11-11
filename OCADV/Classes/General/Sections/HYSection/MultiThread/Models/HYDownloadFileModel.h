//
//  HYDownloadFileModel.h
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, fileDownloadStatus){
    fileDownloadStatusUnDwonload = 1, // 未下载
    fileDownloadStatusDownloading,// 正在下载
    fileDownloadStatusPause,      // 暂停下载
    fileDownloadStatusDownloaded, // 下载完成
};

@interface HYDownloadFileModel : NSObject

// 文件名字(本地设置的文件名)
@property (nonatomic, copy) NSString *name;

// 文件名(下载文件时服务器返回的文件名字)
@property (nonatomic, copy) NSString *remoteName;

// 文件下载状态
@property (nonatomic, assign) fileDownloadStatus downloadStatus;

// 下载地址
@property (nonatomic, copy) NSString *downloadUrl;

// 下载文件的保存路径
@property (nonatomic, copy) NSString *savePath;

// 总时长
@property (nonatomic, copy) NSString *totalDuration;

// 获取总时长完成回调
@property (nonatomic, copy) void (^getDurationComplete)(NSString *duration);

// 已经观看的时长
@property (nonatomic, copy) NSString *playDuration;

// 总大小
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, copy, readonly) NSString *totalSizeFormate;

// 获取总大小完成回调
@property (nonatomic, copy) void (^getTotalSizeComplete)(NSString *size);

// 已经下载的大小
@property (nonatomic, assign) long long downloadLength;
@property (nonatomic, copy, readonly) NSString *downloadSizeFormate;

// 下载进度
@property (nonatomic, assign) double downloadProgress;

+ (instancetype)downloadFileWithDic:(NSDictionary *)dic;

/**
 * 根据本地文件更新下载状态
 */
- (void)reloadDownloadStatus;

@end

NS_ASSUME_NONNULL_END
