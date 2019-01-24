//
//  HYAVUtil.m
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYAVUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define KAVPLAYERKEY @"avplayer"
#define KAVPLAYEROUTPUTKEY @"avplayerOutput"
#define KGETSTREAMTHUMBNAILIMGCOMPLETE @"getStramThumbnailImgComplete"
#define KGETSTREAMTHUMBNAILTIMEKEY @"getStreamThumbnailTime"

@interface HYAVUtil ()

// 获取直播视频缩略图存储的信息
@property (nonatomic, strong) NSMutableDictionary *streamVideoThumbnailImgInfos;

//@property (nonatomic, strong) AVPlayer *player;
//@property (nonatomic, strong) AVPlayerItemVideoOutput *itemOutput;
//@property (nonatomic, assign) double time;
//@property (nonatomic, copy) void (^getThumbnailComplete)(BOOL success,UIImage *image);

@end

@implementation HYAVUtil

#pragma mark - singleton method
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYAVUtil *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super allocWithZone:zone];
        singleTon.streamVideoThumbnailImgInfos = [NSMutableDictionary dictionary];
    });
    
    return singleTon;
}

/**
 * 获取单利对象
 */
+ (instancetype)share
{
    return [[self alloc]init];
}

#pragma mark - class method
/**
 * 获取视频指定时间点的缩略图(网络视频或本地视频)
 * time 要获取的缩略图时间点
 * urlString 网络视频地址/本地视频路径
 * complete 获取完成回调
 */
+ (void)getVideoThumbnailAtTime:(double)times url:(NSString *)urlString complete:(void (^)(UIImage *image,double currentTime))complete
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [self getUrl:urlString];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        // 设定缩略图的方向，如果不设定，可能会在视频旋转90/180/270°时，获取到的缩略图是被旋转过的，而不是正向的。
        gen.appliesPreferredTrackTransform = YES;
        // 取第几秒的缩略图，一秒钟600帧
        CMTime time = CMTimeMakeWithSeconds(times, 600);;
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(thumb,times);
            }
        });
    });
}

/**
 * 获取视频的尺寸(网络视频或本地视频)
 * urlString 网络视频地址/本地视频路径
 * complete 获取完成回调
 */
+ (void)getVideoNaturalSizeWithUrl:(NSString *)urlString complete:(void (^)(CGSize videoSize))complete
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [self getUrl:urlString];
        
        //获取视频尺寸
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        NSArray *array = asset.tracks;
        CGSize videoSize = CGSizeZero;
        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoSize = track.naturalSize;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(videoSize);
            }
        });
    });
}

/**
 * 获取视频时长(网络视频或本地视频)
 * urlString 网络视频地址/本地视频地址
 * complete 获取视频时长后回调
 */
+ (void)getVideoDurationWithUrl:(NSString *)urlString complete:(void (^)(double duration))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [self getUrl:urlString];
        
        NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:[NSNumber numberWithBool:NO]};
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:options];
        double seconds = asset.duration.value/asset.duration.timescale;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(seconds);
            }
        });
    });
}

/**
 * 获取视频大小(网络视频或本地视频)
 * urlString 网络视频地址/本地视频绝对路径
 * complete 获取到视频大小回调
 */
+ (void)getVideoLengthWithUrl:(NSString *)urlString complete:(void (^)(BOOL success,long long videoLength))complete
{
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        NSURL *url = [NSURL URLWithString:urlString];
        
        // 获取网络视频的大小
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:url];
            [mURLRequest setHTTPMethod:@"HEAD"];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            [NSURLConnection sendSynchronousRequest:mURLRequest returningResponse:&response error:&error];
            long long length = 0;
            BOOL requestSuccess = NO;
            if (!error) {
                // 请求成功
                NSDictionary *dict = [(NSHTTPURLResponse *)response allHeaderFields];
                length = [[dict objectForKey:@"Content-Length"] longLongValue];
                requestSuccess = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(requestSuccess,length);
                }
            });
        });
    }else {
        // 获取本地视频的大小
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            long long length = [[fileManager attributesOfItemAtPath:urlString error:&error] fileSize];
            BOOL success = NO;
            if (!error) {
                // 获取成功
                success = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(success,length);
                }
            });
        });
    }
}

/**
 * 获取文件的MIMEType(网络文件或本地文件)
 * urlString 网络文件地址/本地文件路径
 * complete 获取完成回调
 */
+ (void)getFileMimeTypeWithUrl:(NSString *)urlString complete:(void (^)(NSString *mimeType))complete
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *resultMimeType = nil;
        if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
            // 网络文件
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            NSHTTPURLResponse *response = nil;
            [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
            resultMimeType = response.MIMEType;
        }else {
            // 本地文件
            CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[urlString pathExtension], NULL);
            CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
            CFRelease(UTI);
            if (!MIMEType) {
                resultMimeType = @"application/octet-stream";
            }else {
                resultMimeType = (__bridge NSString *)(MIMEType);
            }
        }
        
        // 回到主线程更新界面
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(resultMimeType);
            }
        });
    });
}

/**
 * 根据字符串得到url对象
 */
+ (NSURL *)getUrl:(NSString *)urlString
{
    if (urlString == nil) return nil;
    
    NSURL *url = nil;
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        // 网络
        url = [NSURL URLWithString:urlString];
    }else {
        // 本地
        url = [NSURL fileURLWithPath:urlString];
    }
    
    return url;
}

/**
 * 获取m3u8视频占用存储空间大小和时长
 * urlString m3u8路径
 * complete 获取完成回调
 */
+ (void)getStreamVideoLengthAndDurationWithUr:(NSString *)urlString complete:(void (^)(BOOL success,long long videoLength, double videoDuration))complete
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 获取m3u8中所有的ts文件名
        NSURL *url = [NSURL URLWithString:urlString];
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        content = [content stringByReplacingOccurrencesOfString:@"," withString:@""];
        if (error || content.length == 0) {
            // 请求失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(NO,0,0.0);
                }
            });
        }else {
            // 请求成功
            NSArray *fragmentUrlsAndDuration = [self getSreamVideoFragmentUrlsAndDurationWithUrl:url.absoluteString m3u8Content:content];
            double duration = [fragmentUrlsAndDuration.lastObject doubleValue];
            [self getStreamLengthWithFragments:fragmentUrlsAndDuration.firstObject complete:^(long long length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(YES,length,duration);
                    }
                });
            }];
        }
    });
}

/**
 * 获取所有ts分片的大小并求和，得到总大小
 * fragments 所有的ts分片路径
 * complete 求得最后文件大小回调
 */
+ (void)getStreamLengthWithFragments:(NSArray *)fragments complete:(void (^)(long long length))complete
{
    __block long long length = 0;
    
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    // 创建并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (NSString *fragmentUrl in fragments) {
        // 添加任务到队列
        dispatch_group_async(group, queue, ^{
            NSURL *url = [NSURL URLWithString:fragmentUrl];
            NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:url];
            [mURLRequest setHTTPMethod:@"HEAD"];
            NSHTTPURLResponse *response = nil;
            [NSURLConnection sendSynchronousRequest:mURLRequest returningResponse:&response error:nil];
            NSDictionary *headerFields = response.allHeaderFields;
            long long fragmentLength = [[headerFields objectForKey:@"Content-Length"] longLongValue];
            length += fragmentLength;
        });
    }
    
    // 所有的任务执行完成执行
    dispatch_group_notify(group, queue, ^{
        // 获取到视频总大小
        if (complete) {
            complete(length);
        }
    });
}

/**
 * 解析m3u8所有分片的ts路径
 * m3u8Url m3u8路径
 * m3u8Content包含所有ts分片名字的m3u8内容
 * return 返回数组中包含两个元素，第一个是所有ts地址数组，第二个是m3u8视频的总时长
 */
+ (NSArray *)getSreamVideoFragmentUrlsAndDurationWithUrl:(NSString *)m3u8Url m3u8Content:(NSString *)m3u8Content
{
    // 视频时长
    double duration = 0.0;
    
    NSMutableArray *arrM = [NSMutableArray array];
    NSArray *content = [m3u8Content componentsSeparatedByString:@"\n"];
    
    // 筛选出ts文件名
    for (NSString *str in content) {
        if ([str containsString:@".ts"]) {
            NSString *fragmentUrl = [m3u8Url stringByReplacingOccurrencesOfString:m3u8Url.lastPathComponent withString:str.lastPathComponent];
            [arrM addObject:fragmentUrl];
        }else if ([str containsString:@"#EXTINF"]){
            double fragmentDuration = [[str componentsSeparatedByString:@":"].lastObject doubleValue];
            duration += fragmentDuration;
        }
    }
    
    // 把所有的ts地址和视频总的时长包装成数组返回
    NSArray *result = @[[arrM copy],@(duration)];
    return result;
}

#pragma mark - instance method
/**
 * 获取直播视频指定时间的缩略图
 */
- (void)getStreamVideoThumbnailImages:(NSURL *)url timeInterval:(double)timeInterval complete:(void (^)(BOOL success, UIImage *image))complete
{
    
}

/**
 * 获取直播视频指定时间的缩略图
 */
- (void)getStreamVideoThumbnailImage:(NSURL *)url time:(double)time complete:(void (^)(BOOL success, UIImage *image))complete
{
    // 查看缓存
    NSMutableDictionary *dicM = [self.streamVideoThumbnailImgInfos objectForKey:url.absoluteString];
    AVPlayerItem *playerItem = (AVPlayerItem *)[dicM[KAVPLAYERKEY] currentItem];
    if (dicM) {
        // 缓存中有播放器相关信息
        
    }else {
        // 播放器中没有相关信息，创建
        AVPlayer *player = [[AVPlayer alloc]init];
        playerItem = [AVPlayerItem playerItemWithURL:url];
        AVPlayerItemVideoOutput *itemOutput = [[AVPlayerItemVideoOutput alloc]init];
        [playerItem addOutput:itemOutput];
        [player replaceCurrentItemWithPlayerItem:playerItem];
        
        // 保存相关信息
        dicM = [NSMutableDictionary dictionary];
        [dicM setObject:player forKey:KAVPLAYERKEY];
        [dicM setObject:itemOutput forKey:KAVPLAYEROUTPUTKEY];
        [dicM setObject:[NSNumber numberWithDouble:time] forKey:KGETSTREAMTHUMBNAILTIMEKEY];
        if (complete) {
            [dicM setObject:complete forKey:KGETSTREAMTHUMBNAILIMGCOMPLETE];
        }
        
        [self.streamVideoThumbnailImgInfos setObject:dicM forKey:url.absoluteString];
    }
    
    // 添加监听播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

/**
 * 监听到播放状态改变
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    AVPlayerItem *playerItem = object;
    AVURLAsset *asset = (AVURLAsset *)playerItem.asset;
    
    // 取出视频播放相关信息
    NSDictionary *dict = self.streamVideoThumbnailImgInfos[asset.URL.absoluteString];

    if (dict == nil) {
        NSLog(@"获取缩略图失败:%@",self.streamVideoThumbnailImgInfos);
        return;
    }
    
    // 获取缩略图完成回调
    void (^comp)(BOOL,UIImage *) = dict[KGETSTREAMTHUMBNAILIMGCOMPLETE];
    
    // 获取对应的播放器
    AVPlayer *player = dict[KAVPLAYERKEY];
    
    // playerOutput
    AVPlayerItemVideoOutput *output = dict[KAVPLAYEROUTPUTKEY];
    
    // 时间点
    double time = [dict[KGETSTREAMTHUMBNAILTIMEKEY] doubleValue];
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        BOOL success = NO;
        if(status==AVPlayerStatusReadyToPlay){
            // 正在播放
            success = YES;
        }else if (status == AVPlayerStatusFailed){
            // 播放失败
            NSLog(@"播放失败");
        }else if (status == AVPlayerStatusUnknown){
            // 其他错误
            NSLog(@"未知错误");
        }
        
        // 加载失败
        if (!success) {
            [playerItem removeObserver:self forKeyPath:@"status"];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (comp) {
                    comp(success,nil);
                }
            });
        }else {
            // 跳转到需要截图的位置
            [player seekToTime:CMTimeMake(time, 1) completionHandler:^(BOOL finished) {
                // 获取缩略图
                UIImage *image = [self getStreamThumbnailImageWithUrl:asset.URL.absoluteString playerOutput:output];
                
                [playerItem removeObserver:self forKeyPath:@"status"];
                if (comp) {
                    comp(success,image);
                }
            }];
        }
    }
}

/**
 * 获取缩略图
 */
- (UIImage *)getStreamThumbnailImageWithUrl:(NSString *)url playerOutput:(AVPlayerItemVideoOutput *)outPut
{
    NSDictionary *dict = self.streamVideoThumbnailImgInfos[url];
    AVPlayer *player = dict[KAVPLAYERKEY];
    CVPixelBufferRef pixelBuffer = [outPut copyPixelBufferForItemTime:player.currentTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage
                                                   fromRect:CGRectMake(0, 0,
                                                                       CVPixelBufferGetWidth(pixelBuffer),
                                                                       CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *frameImg = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    //不释放会造成内存泄漏
    CVBufferRelease(pixelBuffer);
    
    return frameImg;
}

@end
