//
//  HYMoviePlayerControllerUtil.h
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYMoviePlayerControllerUtil : NSObject

// 播放器view
@property (nonatomic, weak, readonly) UIView *playView;

// 控制面板风格
@property (nonatomic, assign) MPMovieControlStyle controlStyle;

// 视频开始播放的时间(用于从上次播放的位置继续播放) 单位秒
@property (nonatomic, assign) double initialPlaybackTime;

// 视频当前播放的时间点 单位秒
@property (nonatomic, assign, readonly) double currentPlaybackTime;

// 准备好播放回调
@property (nonatomic, copy) void (^prepareToPlayBlock)(void);


#pragma mark - control method
/**
 * 播放
 */
- (void)play;

/**
 * 暂停播放
 */
- (void)pause;

/**
 * 停止播放
 */
- (void)stopPlay;

/**
 * 跳转到指定的位置播放
 */
- (void)seekToTime:(double)seconds;


/**
 * 创建视频播放对象
 * url 在线视频的播放地址
 * autoPlay 是否自动播放
 * return 播放器view
 */
- (UIView *)createVideoPlayerWithUrl:(NSURL *)url autoPlay:(BOOL)autoPlay;

- (void)loadMovieThumbnailImageAtTime:(double)times;

@end

NS_ASSUME_NONNULL_END
