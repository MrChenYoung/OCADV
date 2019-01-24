//
//  HYVideoModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYBaseVideoModel.h"

@interface HYBaseVideoModel ()

// 视频的url对象(根据urlString判断是本地还是网络视频)
@property (nonatomic, strong, readwrite) NSURL *url;

// 缩略图对应的时间数组(通过设置时间间隔计算)
@property (nonatomic, strong, readwrite) NSArray *thumbnailTimes;
// 所有的缩略图集合
@property (nonatomic, strong, readwrite) NSMutableDictionary *thumbnails;

@end

@implementation HYBaseVideoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化默认信息
        [self initialDefaultInfo];
    }
    return self;
}

#pragma mark - custom method
/**
 * 初始化默认信息
 */
- (void)initialDefaultInfo
{
    // 初始化的播放状态为加载缩略图中
    self.playStatus = videoPlayStatusLoadingThumbnail;
    
    // 初始视频尺寸
    self.naturalSize = CGSizeMake(ScWidth, 200);
    
    // 时长
    self.totalDuration = 0;
    self.totalDurationFormat = @"0s";
    
    // 大小
    self.videoLengthFormat = @"0kb";
    
    // 默认最后一次播放位置
    self.lastPlaySeconds = 1.0;
    
    // 默认1秒取一次缩略图
    self.thumbnailTimeInterval = 1;
    
    // 初始化缩略图容器
    self.thumbnails = [NSMutableDictionary dictionary];
}

#pragma mark - setter getter
/**
 * 在设置url的时候获取缩略图
 */
- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    // 加载视频时长
    if (self.totalDuration == 0) {
        [self loadVideoDurationComplete:^(NSString * _Nonnull duration) {
            // 加载缩略图时间点集合
            if (self.thumbnailTimes.count == 0) {
                [self loadThumbnailTimes];
            }
        }];
    }
}

/**
 * 获取网络文件的地址或本地文件的路径
 */
- (NSURL *)url
{
    if (self.urlString == nil) return nil;
    
    if ([self.urlString hasPrefix:@"http://"] || [self.urlString hasPrefix:@"https://"]) {
        return [NSURL URLWithString:self.urlString];
    }else {
        return [NSURL fileURLWithPath:self.urlString];
    }
}

/**
 * 设置获取缩略图时间间隔
 */
- (void)setThumbnailTimeInterval:(NSInteger)thumbnailTimeInterval
{
    _thumbnailTimeInterval = thumbnailTimeInterval;
    
    if (self.totalDuration > 0) {
        [self loadThumbnailTimes];
    }else {
        [self loadVideoDurationComplete:^(NSString * _Nonnull duration) {
            [self loadThumbnailTimes];
        }];
    }
}

/**
 * 计算缩略图对应的所有时间点
 */
- (void)loadThumbnailTimes
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 计算缩略图对应的所有时间点
        NSMutableArray *arrM = [NSMutableArray array];
        for (int i = 0; i < self.totalDuration;) {
            [arrM addObject:[NSNumber numberWithInt:i]];
            
            i += self.thumbnailTimeInterval;
        }
        
        self.thumbnailTimes = [arrM copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.loadThumbnailTimesBlock) {
                self.loadThumbnailTimesBlock();
            }
        });
    });
}

/**
 * 加载视频时长
 * complete 获取到视频时长回调
 */
- (void)loadVideoDurationComplete:(nullable void (^)(NSString *duration))complete
{
    
}

/**
 * 加载视频的缩略图
 * complete 获取到缩略图 如果获取不到返回image为空
 */
- (void)loadVideoThumbnailComplete:(nullable void (^)(UIImage *image))complete
{
    
}

/**
 * 加载视频的实际尺寸
 * complete 获取到视频实际尺寸
 */
- (void)loadVideoNaturalSizeComplete:(nullable void (^)(CGSize videoSize))complete
{
    
}

/**
 * 加载视频占用存储空间大小
 * complete 获取完成回调
 */
- (void)loadVideoLengthComplete:(nullable void (^)(NSString *videoLengthFormat))complete
{
    
}

/**
 * 加载所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadVideoAllThumbnailsComplete:(void (^)(UIImage *responseImage, int time))complete
{
    
}

@end
