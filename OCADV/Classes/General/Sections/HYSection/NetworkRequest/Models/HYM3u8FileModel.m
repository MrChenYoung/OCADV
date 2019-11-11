//
//  HYM3u8FileModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYM3u8FileModel.h"

@interface HYM3u8FileModel ()

// 文件总大小格式化
@property (nonatomic, copy, readwrite) NSString *totalLengthFormate;

@end

@implementation HYM3u8FileModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


/**
 * 设置相关存储路径
 */
- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    _timeInterval = timeInterval;
    
    
    NSString *dirName = [NSString stringWithFormat:@"%.f",timeInterval];
    
    // 获取document路径
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    // 创建m3u8下载文件存储主目录
    NSString *mainPath = [documentDir stringByAppendingPathComponent:@"m3u8"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:mainPath]) {
        // 如果目录不存在 创建
        [fileManager createDirectoryAtPath:mainPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // m3u8源文件存储路径
    NSString *originalDir = [mainPath stringByAppendingPathComponent:@"originalU3m8"];
    if (![fileManager fileExistsAtPath:originalDir]) {
        // 如果存储源文件的文件夹不存在 创建
        [fileManager createDirectoryAtPath:originalDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.originalSavePath = [originalDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u8",dirName]];
    
    // 创建所有ts文件存储目录
    self.tsSaveDir = [mainPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_ts_list",dirName]];
    if (![fileManager fileExistsAtPath:self.tsSaveDir]) {
        [fileManager createDirectoryAtPath:self.tsSaveDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 所有分片合成后的ts文件存储路径
    NSString *mergeTsFileDir = [mainPath stringByAppendingPathComponent:@"mergedTs"];
    if (![fileManager fileExistsAtPath:mergeTsFileDir]) {
        [fileManager createDirectoryAtPath:mergeTsFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.mergeTsFileSavePath = [mergeTsFileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_merge.ts",dirName]];
    
    // 合并后的ts文件转换成mp4文件存储路径
    NSString *convertResultFileDir = [mainPath stringByAppendingPathComponent:@"convertResult"];
    if (![fileManager fileExistsAtPath:convertResultFileDir]) {
        [fileManager createDirectoryAtPath:convertResultFileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.convertResultFilePath = [convertResultFileDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",dirName]];
    
    // 默认当前下载的分片index为0
    self.downloadFrameIndex = 0;
}

/**
 * 格式化文件总大小
 */
- (void)setTotalLength:(long long)totalLength
{
    _totalLength = totalLength;
    self.totalLengthFormate = [NSByteCountFormatter stringFromByteCount:totalLength countStyle:NSByteCountFormatterCountStyleFile];
}

@end
