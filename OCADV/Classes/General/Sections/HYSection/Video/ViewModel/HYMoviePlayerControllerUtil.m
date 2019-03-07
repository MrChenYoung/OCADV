//
//  HYMoviePlayerControllerUtil.m
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYMoviePlayerControllerUtil.h"
#import <AVFoundation/AVFoundation.h>

#define KPlayerControllerKey @"playerController"
#define KplayerView @"playerView"

@interface HYMoviePlayerControllerUtil ()

// 播放器
@property (nonatomic, strong) MPMoviePlayerController *playerController;

// 播放器view
@property (nonatomic, weak, readwrite) UIView *playView;

// 播放地址数组
@property (nonatomic, strong) NSURL *url;

@end

@implementation HYMoviePlayerControllerUtil


#pragma mark - getter setter

/**
 * 获取播放视图
 */
- (UIView *)playView
{
    return self.playerController.view;
}

/**
 * 设置视频开始播放的时间点
 */
- (void)setInitialPlaybackTime:(double)initialPlaybackTime
{
    _initialPlaybackTime = initialPlaybackTime;
    
    self.playerController.initialPlaybackTime = initialPlaybackTime;
}

/**
 * 获取视频当前播放的时间点
 */
- (double)currentPlaybackTime
{
    return self.playerController.currentPlaybackTime;
}

/**
 * 设置控制面板风格
 */
- (void)setControlStyle:(MPMovieControlStyle)controlStyle
{
    _controlStyle = controlStyle;
    self.playerController.controlStyle = controlStyle;
}

#pragma mark - custom method
/**
 * 创建视频播放对象
 * url 在线视频的播放地址
 * autoPlay 是否自动播放
 * return 播放器view
 */
- (UIView *)createVideoPlayerWithUrl:(NSURL *)url autoPlay:(BOOL)autoPlay
{
    return [self initialPlayerWithUrl:url autoPlay:autoPlay];
}

/**
 * 初始化播放器
 * url 播放url
 * autoPlay 是否自动播放
 * return 返回创建的播放器view
 */
- (UIView *)initialPlayerWithUrl:(NSURL *)url autoPlay:(BOOL)autoPlay
{
    // 播放地址为空什么也不做
    __weak typeof(self) weakSelf = self;
    if (url == nil) return nil;
    
    // 创建MPMoviePlayerController对象
    self.playerController = [[MPMoviePlayerController alloc]initWithContentURL:url];

    // 设置是否自动播放(默认YES)
    _playerController.shouldAutoplay = autoPlay;
    
    //设置控制面板风格
    _playerController.controlStyle = MPMovieControlStyleNone;
    
    //设置播放器显示模式，类似于图片的处理，设置Fill有可能造成部分区域被裁剪
    _playerController.scalingMode = MPMovieScalingModeAspectFit;
    
    // 设置播放器view的大小
    // 默认size(屏幕宽度,200)
    [self updatePlayViewFrame:CGSizeMake([UIScreen mainScreen].bounds.size.width, 200)];
    [HYAVUtil getVideoNaturalSizeWithUrl:self.url complete:^(CGSize videoSize) {
        [weakSelf updatePlayViewFrame:videoSize];
    }];
    
    //播放前的准备，会中断当前正在活跃的音频会话
    [_playerController  prepareToPlay];

    // 添加获取到视频的实际尺寸通知(只要将MPMoviePlayerController的view添加到其他视图上才能调用)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveVedioNaturalSize:) name:MPMovieNaturalSizeAvailableNotification object:nil];
    
    // 准备好播放以后通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePrepareToPlay) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
    
    // 确定播放时长通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDuration) name:MPMovieDurationAvailableNotification object:nil];
    
    // 获取到缩略图通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveThumbnailImage:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    
    // 媒体网络加载状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

    return _playerController.view;
}

/**
 * 更新视频播放器view的size
 */
- (void)updatePlayViewFrame:(CGSize)videoSize
{
    if (!CGSizeEqualToSize(videoSize, CGSizeZero)) {
        // 更新playView的size(宽度和屏幕宽度相同)
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat playViewH = screenSize.width / videoSize.width * videoSize.height;
        CGRect frame = self.playerController.view.frame;
        frame.size = CGSizeMake(screenSize.width, playViewH);
        self.playerController.view.frame = frame;
    }
}

- (void)loadMovieThumbnailImageAtTime:(double)times
{
    [self.playerController requestThumbnailImagesAtTimes:@[@(times)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

#pragma mark - control method
/**
 * 播放
 */
- (void)play
{
    [self.playerController play];
}

/**
 * 暂停播放
 */
- (void)pause
{
    [self.playerController pause];
}

/**
 * 停止播放
 */
- (void)stopPlay
{
    [self.playerController stop];
}

/**
 * 跳转到指定的位置播放
 */
- (void)seekToTime:(double)seconds
{
    self.playerController.initialPlaybackTime = seconds;
}

#pragma mark - notification Action

/**
 * 确定视频尺寸以后回调
 */
- (void)receiveVedioNaturalSize:(NSNotification *)notification
{
    // 更新播放器view的size
    [self updatePlayViewFrame:self.playerController.naturalSize];
}

/**
 * 做好播放准备以后调用
 */
- (void)receivePrepareToPlay
{
    if (self.prepareToPlayBlock) {
        self.prepareToPlayBlock();
    }
}

/**
 * 确定播放时长
 */
- (void)receiveDuration
{
    
    NSLog(@"确定播放时长:%f,%f",self.playerController.duration,self.playerController.playableDuration);
}

/**
 * 获取到缩略图
 */
- (void)receiveThumbnailImage:(NSNotification *)notification
{
    UIImage *thumbnailImage = notification.userInfo[MPMoviePlayerThumbnailImageKey];
    NSLog(@"获取到缩略提：%@",thumbnailImage);
}

/**
 * 网络加载状态发生改变
 */
- (void)receiveLoadStateDidChange
{
    NSLog(@"网络状态发生改变:%f",self.playerController.currentPlaybackTime);
}

@end
