//
//  HYVideoModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYBaseVideoModel.h"

@interface HYBaseVideoModel ()

// 视频总时长格式化
@property (nonatomic, copy, readwrite) NSString *totalDurationFormat;
// 视频占用存储空间大小格式化
@property (nonatomic, copy, readwrite) NSString *videoLengthFormat;
// 所有的缩略图集合
@property (nonatomic, strong, readwrite) NSMutableDictionary *thumbnails;
// 缩略图对应的时间数组(通过设置时间间隔计算)
@property (nonatomic, strong, readwrite) NSArray *thumbnailTimes;


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

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        // 视频标题
        self.title = dic[@"fileName"];
        
        // 路径(播放地址/存储路径)
        self.urlString = dic[@"url"];
        
        // 初始化默认信息
        [self initialDefaultInfo];
    }
    
    return self;
}

+ (instancetype)videoWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}

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
    
    // 默认1秒取一次缩略图
    self.thumbnailTimeInterval = 1;
    
    // 默认最后一次播放位置
    self.lastPlaySeconds = 1.0;
    
    // 初始化缩略图容器
    self.thumbnails = [NSMutableDictionary dictionary];
}

#pragma mark - setter
/**
 * 在设置url的时候获取缩略图
 */
- (void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    
    
    if (urlString == nil || urlString.length == 0) return;
    
    // 设置url
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        url = [NSURL fileURLWithPath:urlString];
    }
    self.url = url;
    
    // 加载视频时长
    if (self.totalDuration == 0) {
        [self loadVideoDurationComplete:^(NSString * _Nonnull duration) {
            // 加载缩略图时间点集合
            if (self.thumbnailTimes.count == 0) {
                [self loadThumbnailTimes];
            }
        }];
    }
    
    // 加载视频尺寸
    if (self.naturalSize.width <= 0 || self.naturalSize.height <= 0) {
        [self loadVideoNaturalSizeComplete:nil];
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

#pragma mark - custom method
/**
 * 加载视频的缩略图
 * complete 获取到缩略图 如果获取不到返回image为空
 */
- (void)loadVideoThumbnailComplete:(void (^)(UIImage *image))complete
{
    if (self.url == nil) return;
    
    // 获取视频缩略图
    [HYAVUtil getVideoThumbnailAtTime:self.lastPlaySeconds url:self.url complete:^(UIImage * _Nonnull image, double currentTime) {
        self.thumbnail = image;
        
        if (complete) {
            complete(image);
        }
        
        if (self.loadedThumbnailBlock) {
            self.loadedThumbnailBlock(image);
        }
    }];
}

/**
 * 加载视频的实际尺寸
 * complete 获取到视频实际尺寸
 */
- (void)loadVideoNaturalSizeComplete:(void (^)(CGSize videoSize))complete
{
    if (self.url == nil) return;
    
    // 获取视频size
    [HYAVUtil getVideoNaturalSizeWithUrl:self.url complete:^(CGSize videoSize) {
        if (videoSize.width > 0 && videoSize.height > 0) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGFloat height = screenSize.width / videoSize.width * videoSize.height;
            self.naturalSize = CGSizeMake(screenSize.width, height);
        }else {
            self.naturalSize = CGSizeZero;
        }
        
        if (complete) {
            complete(self.naturalSize);
        }
        
        if (self.loadedNaturalSizeBlock) {
            self.loadedNaturalSizeBlock(self.naturalSize);
        }
    }];
}

/**
 * 加载视频时长
 * complete 获取到视频时长回调
 */
- (void)loadVideoDurationComplete:(void (^)(NSString *duration))complete
{
    if (self.url == nil) return;
    
    // 获取视频时长
    [HYAVUtil getVideoDurationWithUrl:self.url complete:^(double duration) {
        self.totalDuration = duration;
        NSString *durationString = [NSDate timeFormat:duration];
        self.totalDurationFormat = durationString;
        
        if (complete) {
            complete(durationString);
        }
        
        if (self.getVideoDurationBlock) {
            self.getVideoDurationBlock(durationString);
        }
    }];
}

/**
 * 加载视频占用存储空间大小
 * complete 获取完成回调
 */
- (void)loadVideoLengthComplete:(void (^)(NSString *videoLengthFormat))complete
{
    if (self.url == nil) return;
    
    // 获取视频占用存储空间大小
    [HYAVUtil getVideoLengthWithUrl:self.url complete:^(BOOL success,long long videoLength) {
        self.videoLength = videoLength;
        self.videoLengthFormat = [NSByteCountFormatter stringFromByteCount:videoLength countStyle:NSByteCountFormatterCountStyleFile];
        
        if (complete) {
            complete(self.videoLengthFormat);
        }
        if (self.getVideoLengthBlock) {
            self.getVideoLengthBlock(self.videoLengthFormat);
        }
    }];
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
 * 加载所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadVideoAllThumbnailsComplete:(void (^)(UIImage *responseImage, int time))complete
{
    if (self.url == nil) return;
    
    [self.thumbnails removeAllObjects];
    for (NSNumber *time in self.thumbnailTimes) {
        [HYAVUtil getVideoThumbnailAtTime:time.doubleValue url:self.url complete:^(UIImage * _Nonnull image, double currentTime) {
            UIImage *thumbnail = image ? image : [UIImage imageNamed:@"placeHold"];
            [self.thumbnails setObject:thumbnail forKey:[NSNumber numberWithInt:(int)currentTime]];
            
            if (complete) {
                complete(thumbnail,(int)currentTime);
            }
        }];
    }
}

@end
