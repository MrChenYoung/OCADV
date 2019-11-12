//
//  HYAVUtil.h
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYAVUtil : NSObject

#pragma mark - singleton method
/**
 * 获取单利对象
 */
+ (instancetype)share;

#pragma mark - class method
/**
 * 获取视频指定时间点的缩略图(网络视频或本地视频)
 * time 要获取的缩略图时间点
 * urlString 网络视频地址/本地视频路径
 * complete 获取完成回调
 */
+ (void)getVideoThumbnailAtTime:(double)times url:(NSString *)urlString complete:(void (^)(UIImage *image,double currentTime))complete;

/**
 * 获取视频的尺寸(网络视频或本地视频)
 * urlString 网络视频地址/本地视频路径
 * complete 获取完成回调
 */
+ (void)getVideoNaturalSizeWithUrl:(NSString *)urlString complete:(void (^)(CGSize videoSize))complete;

/**
 * 获取视频时长(网络视频或本地视频)
 * urlString 网络视频地址/本地视频地址
 * complete 获取视频时长后回调
 */
+ (void)getVideoDurationWithUrl:(NSString *)urlString complete:(void (^)(double duration))complete;

/**
 * 获取视频大小(网络视频或本地视频)
 * urlString 网络视频地址/本地视频绝对路径
 * complete 获取到视频大小回调
 */
+ (void)getVideoLengthWithUrl:(NSString *)urlString complete:(void (^)(BOOL success,long long videoLength))complete;

/**
 * 获取文件的MIMEType(网络文件或本地文件)
 * urlString 网络文件地址/本地文件路径
 * complete 获取完成回调
 */
+ (void)getFileMimeTypeWithUrl:(NSString *)urlString complete:(void (^)(NSString *mimeType))complete;

/**
 * 获取m3u8视频占用存储空间大小和时长
 * urlString m3u8路径
 * complete 获取完成回调
 */
+ (void)getStreamVideoLengthAndDurationWithUr:(NSString *)urlString complete:(void (^)(BOOL success,long long videoLength, double videoDuration))complete;

#pragma mark - instance method
/**
 * 获取直播视频指定时间的缩略图
 */
- (void)getStreamVideoThumbnailImage:(NSURL *)url time:(double)time complete:(void (^)(BOOL success, UIImage *image))complete;

@end

NS_ASSUME_NONNULL_END
