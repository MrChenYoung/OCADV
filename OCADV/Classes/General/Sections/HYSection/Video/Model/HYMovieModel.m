//
//  HYMovieModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/18.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYMovieModel.h"
#import "HYMoviePlayerControllerUtil.h"

@interface HYMovieModel ()

// 视频url对象
@property (nonatomic, strong, readwrite) NSURL *url;

// 视频总时长格式化
@property (nonatomic, copy, readwrite) NSString *totalDurationFormat;

// 缩略图对应的时间数组
@property (nonatomic, strong, readwrite) NSArray *thumbnailImageTimesArray;

// 所有的缩略图集合
@property (nonatomic, strong, readwrite) NSMutableDictionary *thumbnailImages;

@end

@implementation HYMovieModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        // 默认url
        self.urlString = @"";
        
        // 初始化视频类型为未知
        self.type = movieTypeUnknown;
        
        // 初始化的播放状态为加载缩略图中
        self.playStatus = moviePlayStatusLoadingThumbnailImage;
        
        // 初始视频尺寸
        self.naturalSize = CGSizeMake(ScWidth, 200);
        
        // 时长
        self.totalDurationFormat = @"0s";
        
        // 大小
        self.videoLength = @"okb";
        
        // 默认1秒取一次缩略图
        self.thumbnailImageTimeInterval = 1;
        
        self.thumbnailImages = [NSMutableDictionary dictionary];
    }
    return self;
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
    
    [self loadMovieInfo];
}

/**
 * 设置获取缩略图时间间隔
 */
- (void)setThumbnailImageTimeInterval:(NSInteger)thumbnailImageTimeInterval
{
    _thumbnailImageTimeInterval = thumbnailImageTimeInterval;
    
    if (self.totalDuration > 0) {
        [self loadThumbnailImageTimes];
    }
}

/**
 * 设置视频类型
 */
- (void)setType:(movieType)type
{
    _type = type;
    
}

#pragma mark - custom method
/**
 * 获取视频信息
 */
- (void)loadMovieInfo
{
    // 获取视频size
    [HYAVUtil getVideoNaturalSizeWithUrl:self.url complete:^(CGSize videoSize) {
        if (videoSize.width > 0 && videoSize.height > 0) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            CGFloat height = screenSize.width / videoSize.width * videoSize.height;
            self.naturalSize = CGSizeMake(screenSize.width, height);
            if (self.loadedNaturalSizeBlock) {
                self.loadedNaturalSizeBlock(self.naturalSize);
            }
        }
    }];
    
    // 获取视频缩略图
    [HYAVUtil getVideoThumbnailAtTime:1.0 url:self.url complete:^(UIImage * _Nonnull image, double currentTime) {
        if (image == nil) return ;
        
        self.thumbnailImage = image;
        if (self.loadedThumbnailImageBlock) {
            self.loadedThumbnailImageBlock(image);
        }
    }];
    
    // 获取视频时长
    [HYAVUtil getVideoDurationWithUrl:self.url complete:^(double duration) {
        self.totalDuration = duration;
        
        // 计算缩略图对应的所有时间点
        [self loadThumbnailImageTimes];
        
        NSString *durationString = [NSDate timeFormat:duration];
        self.totalDurationFormat = durationString;
        if (self.getVideoDurationBlock) {
            self.getVideoDurationBlock(durationString);
        }
    }];
    
    // 获取视频大小
    [HYAVUtil getVideoLengthWithUrl:self.url complete:^(BOOL success,long long videoLength) {
        self.videoLength = [NSByteCountFormatter stringFromByteCount:videoLength countStyle:NSByteCountFormatterCountStyleFile];
    
        if (self.getVideoLengthBlock) {
            self.getVideoLengthBlock(self.videoLength);
        }
    }];
}

/**
 * 计算缩略图对应的所有时间点
 */
- (void)loadThumbnailImageTimes
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 计算缩略图对应的所有时间点
        NSMutableArray *arrM = [NSMutableArray array];
        for (int i = 0; i < self.totalDuration;) {
            [arrM addObject:[NSNumber numberWithInt:i]];
            
            i += self.thumbnailImageTimeInterval;
        }
        
        self.thumbnailImageTimesArray = [arrM copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.loadThumbnailTimesBlock) {
                self.loadThumbnailTimesBlock();
            }
        });
    });
}

/**
 * 获取所有的缩略图
 * complete 获得一张缩略图回调一次
 */
- (void)loadMovieAllThumbnailImagesComplete:(void (^)(UIImage *responseImage, int time))complete
{
    [self.thumbnailImages removeAllObjects];
    for (NSNumber *time in self.thumbnailImageTimesArray) {
        [HYAVUtil getVideoThumbnailAtTime:time.doubleValue url:self.url complete:^(UIImage * _Nonnull image, double currentTime) {
            UIImage *thumbnailImage = image ? image : [UIImage imageNamed:@"placeHold"];
            [self.thumbnailImages setObject:thumbnailImage forKey:[NSNumber numberWithInt:(int)currentTime]];
            
            if (complete) {
                complete(thumbnailImage,(int)currentTime);
            }
        }];
    }
}

@end
