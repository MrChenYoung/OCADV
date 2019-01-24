//
//  HYMovieModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/18.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, movieType) {
    movieTypeUnknown, // 未知类型 没有设置
    movieTypeOnline, // 在线视频
    movieTypeLocal  // 本地视频
};

typedef NS_ENUM(NSUInteger, moviePlayStatus) {
    moviePlayStatusLoadingThumbnailImage, // 加载缩略图中
    moviePlayStatusLoadThumbnailComplete, // 加载缩略图成功
    moviePlayStatusStartPlay, // 开始播放
    moviePlayStatusPrepared, // 准备好播放
    moviePlayStatusPlaying, // 正在播放
    moviePlayStatusPause, // 暂停播放
};

@interface HYMovieModel : NSObject

// 视频名字
@property (nonatomic, copy) NSString *movieName;

// 视频类型(本地视频/在线视频)
@property (nonatomic, assign) movieType type;

// 播放状态
@property (nonatomic, assign) moviePlayStatus playStatus;

// 视频地址(网路地址/本地绝对路径)
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong, readonly) NSURL *url;

// 视频的size
@property (nonatomic, assign) CGSize naturalSize;
// 获取到视频size回调
@property (nonatomic, copy) void (^loadedNaturalSizeBlock)(CGSize size);

// 缩略图
@property (nonatomic, strong) UIImage *thumbnailImage;
// 获取到缩略图回调
@property (nonatomic, copy) void (^loadedThumbnailImageBlock)(UIImage *image);

// 视频时长(单位秒)
@property (nonatomic, assign) int totalDuration;
// 视频总时长格式化
@property (nonatomic, copy, readonly) NSString *totalDurationFormat;
// 获取到视频时长回调
@property (nonatomic, copy) void (^getVideoDurationBlock)(NSString *duration);

// 视频大小
@property (nonatomic, copy) NSString *videoLength;
// 获取到视频大小回调
@property (nonatomic, copy) void (^getVideoLengthBlock)(NSString *videoLength);

// 获取缩略图的时间间隔(默认1秒)
@property (nonatomic, assign) NSInteger thumbnailImageTimeInterval;

// 所有的缩略图集合
@property (nonatomic, strong, readonly) NSMutableDictionary *thumbnailImages;

// 缩略图对应的时间数组(通过设置时间间隔计算)
@property (nonatomic, strong, readonly) NSArray *thumbnailImageTimesArray;

/**
 * 获取视频信息
 */
- (void)loadMovieInfo;

// 缩略图对应的所有时间点获取完成回调
@property (nonatomic, copy) void (^loadThumbnailTimesBlock)(void);

/**
 * 获取所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadMovieAllThumbnailImagesComplete:(void (^)(UIImage *responseImage, int time))complete;

@end

NS_ASSUME_NONNULL_END
