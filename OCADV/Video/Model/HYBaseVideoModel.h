//
//  HYVideoModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, videoPlayStatus) {
    videoPlayStatusLoadingThumbnail, // 加载缩略图中
    videoPlayStatusLoadThumbnailComplete, // 加载缩略图成功
    videoPlayStatusStartPlay, // 开始播放
    videoPlayStatusPrepared, // 准备好播放
    videoPlayStatusPlaying, // 正在播放
    videoPlayStatusPause, // 暂停播放
};

@interface HYBaseVideoModel : NSObject

// 视频标题
@property (nonatomic, copy) NSString *title;
// 路径(播放地址/存储路径)
@property (nonatomic, copy) NSString *urlString;
// 视频的url对象(根据urlString判断是本地还是网络视频)
@property (nonatomic, strong, readonly) NSURL *url;
// 视频状态
@property (nonatomic, assign) videoPlayStatus playStatus;
// 最后一次播放的位置
@property (nonatomic, assign) double lastPlaySeconds;

// 视频时长(单位秒)
@property (nonatomic, assign) double totalDuration;
// 视频总时长格式化
@property (nonatomic, copy) NSString *totalDurationFormat;
// 获取视频时长回调
@property (nonatomic, copy) void (^loadVideoDurationBlock)(NSString *durationFormat);

// 视频占用存储空间大小
@property (nonatomic, assign) long long videoLength;
// 视频占用存储空间大小格式化
@property (nonatomic, copy) NSString *videoLengthFormat;
// 获取到视频时长回调
@property (nonatomic, copy) void (^loadVideoLengthBlock)(NSString *lengthFormate);

// 视频的尺寸
@property (nonatomic, assign) CGSize naturalSize;
@property (nonatomic, copy) void (^loadVideoNaturalSizeBlock)(CGSize videoSize);

// 缩略图
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, copy) void (^loadThumbnailBlock)(UIImage *image);

// 获取所有缩略两张缩略图的时间间隔(默认1秒)
@property (nonatomic, assign) NSInteger thumbnailTimeInterval;
// 缩略图对应的时间数组(通过设置时间间隔计算)
@property (nonatomic, strong, readonly) NSArray *thumbnailTimes;
// 缩略图对应的所有时间点获取完成回调
@property (nonatomic, copy) void (^loadThumbnailTimesBlock)(void);
// 所有的缩略图集合
@property (nonatomic, strong, readonly) NSMutableDictionary *thumbnails;


/**
 * 初始化默认信息
 */
- (void)initialDefaultInfo;

/**
 * 计算缩略图对应的所有时间点
 */
- (void)loadThumbnailTimes;

/**
 * 加载视频时长
 * complete 获取到视频时长回调
 */
- (void)loadVideoDurationComplete:(nullable void (^)(NSString *duration))complete;

/**
 * 加载视频的缩略图
 * complete 获取到缩略图 如果获取不到返回image为空
 */
- (void)loadVideoThumbnailComplete:(nullable void (^)(UIImage *image))complete;

/**
 * 加载视频的实际尺寸
 * complete 获取到视频实际尺寸
 */
- (void)loadVideoNaturalSizeComplete:(nullable void (^)(CGSize videoSize))complete;

/**
 * 加载所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadVideoAllThumbnailsComplete:(void (^)(UIImage *responseImage, int time))complete;

/**
 * 加载视频占用存储空间大小
 * complete 获取完成回调
 */
- (void)loadVideoLengthComplete:(nullable void (^)(NSString *videoLengthFormat))complete;

@end

NS_ASSUME_NONNULL_END
