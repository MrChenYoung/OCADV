//
//  HYMoviesResolver.h
//  OCADV
//
//  Created by MrChen on 2018/12/27.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYDownloadFileModel.h"
#import "HYNormalVideoModel.h"

@interface HYGeneralSingleTon : NSObject

// 请求微信公众平台接口需要的accessToken
@property (nonatomic, copy, readonly) NSString *accessToken;

// 本地视频
@property (nonatomic, strong, readonly) NSMutableArray *localVideos;

// 在线视频
@property (nonatomic, copy, readonly) NSArray *onlineVideos;

// 直播视频
@property (nonatomic, copy, readonly) NSArray *streamVideos;

// 上传到服务器的图片列表信息
@property (nonatomic, strong) NSMutableArray *imageListArray;

// 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
@property (nonatomic, assign, readonly) NSTimeInterval m3u8TimeInterval;

+ (instancetype)share;

/**
 * 获取本地视频(扫描所有的文件夹筛选出视频文件)
 * block 获取到一个视频文件回调一次
 */
- (void)loadLocalVideosBlock:(void (^)(HYNormalVideoModel *model))block;

/**
 * 获取在线视频信息
 */
- (void)loadOnlineVideos;

/**
 * 加载直播回放视频
 */
- (void)loadStreamVideos;

/**
 * accessToken过期以后刷新
 * coreCode 网络请求核心代码
 */
- (void)reloadAccessTokenCoreCode:(void (^)(NSString *urlString, NSDictionary *parameters,void (^success)(NSData *response),void (^faile)(void)))coreCode;

@end
