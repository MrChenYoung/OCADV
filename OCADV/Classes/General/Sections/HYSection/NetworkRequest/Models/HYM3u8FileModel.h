//
//  HYM3u8FileModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, downloadStatus) {
    downloadStatusUndownload, // 未下载状态
    downloadStatusGettingFrames, // 获取分片信息中
    downloadStatusDownloadingFrame, // 下载分片中
    downloadStatusMergeFrames,      // 合并分片中
    downloadStatusConverting,       // 视频格式转换中
    downloadStatusComplete,         // 下载转换完成
    downloadStatusError             // 下载出错
};

@interface HYM3u8FileModel : NSObject

// m3u8文件下载地址
@property (nonatomic, copy) NSString *downloadUrl;

// m3u8文件名字
@property (nonatomic, copy) NSString *fileName;

// m3u8文件总大小
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, copy, readonly) NSString *totalLengthFormate;

// m3u8总共的分片集合
@property (nonatomic, copy) NSArray *tsListsArray;

// 正在下载的分片索引
@property (nonatomic, assign) int downloadFrameIndex;

// m3u8视频下载状态
@property (nonatomic, assign) downloadStatus status;

// 下载/合成视频进度
@property (nonatomic, assign) double progress;

// 下载出错信息描述
@property (nonatomic, copy) NSString *errorMessage;

// m3u8源文件存储路径
@property (nonatomic, copy) NSString *originalSavePath;

// 所有的ts分片存储目录
@property (nonatomic, copy) NSString *tsSaveDir;

// 所有分片合成后的ts文件存储路径
@property (nonatomic, copy) NSString *mergeTsFileSavePath;

// 合并后的ts文件转换成mp4文件存储路径
@property (nonatomic, copy) NSString *convertResultFilePath;

// 时间戳，作为存放文件的文件夹名
@property (nonatomic, assign) NSTimeInterval timeInterval;

@end

NS_ASSUME_NONNULL_END
