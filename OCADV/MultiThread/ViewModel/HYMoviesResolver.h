//
//  HYMoviesResolver.h
//  OCADV
//
//  Created by MrChen on 2018/12/27.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDownloadFileModel.h"

@interface HYMoviesResolver : NSObject

// 所有要下载的电影信息
@property (nonatomic, copy, readonly) NSArray *movies;

// 网络请求篇下载文件的存储路径
@property (nonatomic, copy, readonly) NSString *netDownloadFileSavePath;

// 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
@property (nonatomic, assign, readonly) NSTimeInterval m3u8TimeInterval;

+ (instancetype)share;

@end
