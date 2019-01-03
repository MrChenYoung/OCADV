//
//  HYDownloadFileModel.h
//  OCADV
//
//  Created by MrChen on 2018/12/22.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYDownloadFileModel : NSObject

// 文件名字
@property (nonatomic, copy) NSString *name;

// 下载路径
@property (nonatomic, copy) NSString *downloadUrl;

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

@end

NS_ASSUME_NONNULL_END
