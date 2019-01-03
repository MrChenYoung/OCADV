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

+ (instancetype)share;

@end
