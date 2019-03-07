//
//  HYNormalVideoModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/23.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYNormalVideoModel.h"

@interface HYNormalVideoModel ()

@end

@implementation HYNormalVideoModel

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

#pragma mark - setter getter
/**
 * 在设置url的时候获取缩略图
 */
- (void)setUrlString:(NSString *)urlString
{
    [super setUrlString:urlString];

//    // 加载视频时长
//    if (self.totalDuration == 0) {
//        [self loadVideoDurationComplete:^(NSString * _Nonnull duration) {
//            // 加载缩略图时间点集合
//            if (self.thumbnailTimes.count == 0) {
//                [self loadThumbnailTimes];
//            }
//        }];
//    }
    
    // 加载初始缩略图
//    if (self.thumbnail == nil) {
//        [self loadVideoThumbnailComplete:^(UIImage * _Nonnull image) {
//            if (self.loadThumbnailBlock) {
//                self.loadThumbnailBlock(image);
//            }
//        }];
//    }
//
//    // 加载视频尺寸
//    if (self.naturalSize.width <= 0 || self.naturalSize.height <= 0) {
//        [self loadVideoNaturalSizeComplete:nil];
//    }
//
//    // 加载视频占用存储空间大小
//    if (self.videoLength == 0) {
//        [self loadVideoLengthComplete:nil];
//    }
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
    [HYAVUtil getVideoThumbnailAtTime:self.lastPlaySeconds url:self.urlString complete:^(UIImage * _Nonnull image, double currentTime) {
        self.thumbnail = image;
        
        if (complete) {
            complete(image);
        }
        
        if (self.loadThumbnailBlock) {
            self.loadThumbnailBlock(image);
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
    [HYAVUtil getVideoNaturalSizeWithUrl:self.urlString complete:^(CGSize videoSize) {
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
        
        if (self.loadVideoNaturalSizeBlock) {
            self.loadVideoNaturalSizeBlock(self.naturalSize);
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
    [HYAVUtil getVideoDurationWithUrl:self.urlString complete:^(double duration) {
        self.totalDuration = duration;
        NSString *durationString = [NSDate timeFormat:duration];
        self.totalDurationFormat = durationString;
        
        if (complete) {
            complete(durationString);
        }
        
        if (self.loadVideoDurationBlock) {
            self.loadVideoDurationBlock(durationString);
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
    [HYAVUtil getVideoLengthWithUrl:self.urlString complete:^(BOOL success,long long videoLength) {
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
    
    [self.thumbnails removeAllObjects];
    for (NSNumber *time in self.thumbnailTimes) {
        [HYAVUtil getVideoThumbnailAtTime:time.doubleValue url:self.urlString complete:^(UIImage * _Nonnull image, double currentTime) {
            UIImage *thumbnail = image ? image : [UIImage imageNamed:@"placeHold"];
            [self.thumbnails setObject:thumbnail forKey:[NSNumber numberWithInt:(int)currentTime]];
            
            if (complete) {
                complete(thumbnail,(int)currentTime);
            }
        }];
    }
}

@end
