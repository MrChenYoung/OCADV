//
//  HYStreamVideoModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/23.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYStreamVideoModel.h"
#import <AVFoundation/AVFoundation.h>

@interface HYStreamVideoModel ()

// 播放器
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItemVideoOutput *itemOutput;

// 播放器是否准备好(只有播放器准备好才能获取缩略图)
@property (nonatomic, assign) BOOL playerPrepared;

@end

@implementation HYStreamVideoModel

#pragma mark - lazy loading
/**
 * 播放器
 */
- (AVPlayer *)player
{
    if (_player == nil) {
        _player = [[AVPlayer alloc]init];
    }
    
    return _player;
}

- (AVPlayerItemVideoOutput *)itemOutput
{
    if (_itemOutput == nil) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.url];
        _itemOutput = [[AVPlayerItemVideoOutput alloc]init];
        [item addOutput:_itemOutput];
        [self.player replaceCurrentItemWithPlayerItem:item];
    }
    
    return _itemOutput;
}

#pragma mark - init
- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - setter
/**
 * 设置url
 */
- (void)setUrlString:(NSString *)urlString
{
    [super setUrlString:urlString];
    
    // 加载视频占用存储空间大小
    [self loadVideoLengthComplete:nil];
    
    [self itemOutput];
    
    // 添加观察者
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - custom method
/**
 * 加载视频时长
 * complete 获取到视频时长回调
 */
- (void)loadVideoDurationComplete:(nullable void (^)(NSString *duration))complete
{
    double videoDuration = 0;
    if (!self.playerPrepared) {
        NSLog(@"播放器还没有准备好");
    }else {
        videoDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    }
    
    self.totalDuration = videoDuration;
    NSString *durationString = [NSDate timeFormat:videoDuration];
    self.totalDurationFormat = durationString;
    if (complete) {
        complete(durationString);
    }
    if (self.loadVideoDurationBlock) {
        self.loadVideoLengthBlock(durationString);
    }
}

/**
 * 加载视频的实际尺寸
 * complete 获取到视频实际尺寸
 */
- (void)loadVideoNaturalSizeComplete:(nullable void (^)(CGSize videoSize))complete
{
    if (complete) {
        complete(self.thumbnail.size);
    }
}

/**
 * 加载视频的缩略图
 * complete 获取到缩略图 如果获取不到返回image为空
 */
- (void)loadVideoThumbnailComplete:(nullable void (^)(UIImage *image))complete
{
    if (self.url == nil) return;
    
    if (!self.playerPrepared) {
        [HYToast toastWithMessage:@"播放器还没有准备好"];
        if (complete) {
            complete(nil);
        }
        return;
    }
    
    // 播放器移动到指定的位置才能获取缩略图
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:CMTimeMake(self.lastPlaySeconds, 1) completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [weakSelf getThumbnail];
            self.naturalSize = image.size;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(image);
                }
            });
        });
    }];
}

/**
 * 获取播放器当前播放位置的视频截图
 */
-(UIImage *)getThumbnail{
    CVPixelBufferRef pixelBuffer = [self.itemOutput copyPixelBufferForItemTime:self.player.currentTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *frameImg = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    //不释放会造成内存泄漏
    CVBufferRelease(pixelBuffer);
    
    return frameImg;
}

/**
 * 加载视频占用存储空间大小
 * complete 获取完成回调
 */
- (void)loadVideoLengthComplete:(void (^)(NSString *videoLengthFormat))complete
{
    if (self.url == nil) return;
    
    // 获取视频占用存储空间大小
    [HYAVUtil getStreamVideoLengthAndDurationWithUr:self.urlString complete:^(BOOL success, long long videoLength, double videoDuration) {
        self.videoLength = videoLength;
        self.videoLengthFormat = [NSByteCountFormatter stringFromByteCount:videoLength countStyle:NSByteCountFormatterCountStyleFile];
        
        if (complete) {
            complete(self.videoLengthFormat);
        }
        if (self.loadVideoLengthBlock) {
            self.loadVideoLengthBlock(self.videoLengthFormat);
        }
    }];
}

/**
 * 加载所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadVideoAllThumbnailsComplete:(void (^)(UIImage *responseImage, int time))complete
{
    if (self.url == nil) return;
    
    if (self.thumbnailTimes.count > 0) {
        [self.thumbnails removeAllObjects];
        [self getThumbnailWithTimeIndex:0 complete:complete];
    }
}

/**
 * 获取缩略图时间点数组中指定索引的缩略图
 */
- (void)getThumbnailWithTimeIndex:(int)timeIndex complete:(void (^)(UIImage *responseImage, int time))complete
{
    __block int index = timeIndex;
    int time = [self.thumbnailTimes[timeIndex] intValue];
    [self.player seekToTime:CMTimeMake(time, 1) completionHandler:^(BOOL finished) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *image = [self getThumbnail];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *thumbnail = image ? image : [UIImage imageNamed:@"placeHold"];
                [self.thumbnails setObject:thumbnail forKey:[NSNumber numberWithInt:(int)time]];
                
                if (complete) {
                    complete(image,time);
                }
                
                // 递归请求下一张图片
                [self getThumbnailWithTimeIndex:++index complete:complete];
            });
        });
    }];
    
}

#pragma mark - observer
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    AVPlayerItem *item = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            self.playerPrepared = YES;
            
            // 加载视频时长
            if (self.totalDuration == 0) {
                [self loadVideoDurationComplete:^(NSString * _Nonnull duration) {
                    // 加载默认的缩略图时间点集合
                    if (self.thumbnailTimes.count == 0) {
                        [self loadThumbnailTimes];
                    }
                    
                    // 加载视频时长完成回调
                    if (self.loadVideoDurationBlock) {
                        self.loadVideoDurationBlock(duration);
                    }
                }];
            }
            
            // 加载初始缩略图
            if (self.thumbnail == nil) {
                [self loadVideoThumbnailComplete:^(UIImage * _Nonnull image) {
                    // 设置缩略图
                    self.thumbnail = image;
                    if (self.loadThumbnailBlock) {
                        self.loadThumbnailBlock(image);
                    }
                    
                    // 视频的实际尺寸和缩略图的尺寸一样
                    CGSize videoSize = image.size;
                    CGSize screenSize = [UIScreen mainScreen].bounds.size;
                    CGFloat height = screenSize.width / videoSize.width * videoSize.height;
                    self.naturalSize = CGSizeMake(screenSize.width, height);
                    if (self.loadVideoNaturalSizeBlock) {
                        self.loadVideoNaturalSizeBlock(self.naturalSize);
                    }
                }];
            }
        }else if (status == AVPlayerStatusFailed){
            NSLog(@"播放失败");
        }else if (status == AVPlayerStatusUnknown){
            NSLog(@"未知错误");
        }
        
        // 移除观察者
        [item removeObserver:self forKeyPath:@"status"];
        
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        //        NSArray *array=playerItem.loadedTimeRanges;
        //        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        //        float startSeconds = CMTimeGetSeconds(timeRange.start);
        //        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        //        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

@end
