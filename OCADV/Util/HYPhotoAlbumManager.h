//
//  HYPhotoAlbumManager.h
//  XRWaterfallLayoutDemo
//
//  Created by MrChen on 2018/3/22.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>   // iOS8.0以后的新库
#import <AssetsLibrary/AssetsLibrary.h> // iOS8.0以前的老库,iOS9.0以后开始废弃

@interface HYPhotoAlbumManager : NSObject

// 获取单利
+ (instancetype)shareManager;

#pragma mark - AssetsLibrary库
/**
 * get photos(异步获取)
 * assert 每次遍历获取的单张照片对象(直接转换成UIImage对象速度太慢,所以返回ALAsset对象,每次给UIImageView设置image的时候再转换)
 */
- (void)getAllPhotosBlock:(void (^)(ALAsset *assert))stepPhotoBlock;

/**
 * 根据照片对象获取缩略图(太模糊,不建议使用)
 * assert 照片对象
 */
- (UIImage *)thumbnailWithAssert:(ALAsset *)assert;

/**
 * 根据照片对象获取大尺寸图片(系统相册使用,建议使用)
 * assert 照片对象
 */
- (UIImage *)fullScreenImageWithAssert:(ALAsset *)assert;

/**
 * 根据照片对象获取超大尺寸图片(太大,不建议使用)
 * assert 照片对象
 */
- (UIImage *)fullResolutionImageWithAssert:(ALAsset *)assert;

/**
 * 根据照片对象获取图片名字
 * assert 照片对象
 */
- (NSString *)imageNameWithAssert:(ALAsset *)assert;


#pragma mark - Photos库
/**
 * 获取所有照片(因为请求用户授权是异步的，所以用回调的方式)
 * complete 完成回调
 */
- (void)getAllPhototsComplete:(void (^)(NSArray <PHAsset *>*result))complete;

/**
 * 获取照片(缩略图/原图)
 * assert 照片对象
 * synchronous 是否是同步请求
 * original 是否是原图
 * complete 获取照片后回调(异步获取使用)
 * return 获取的照片(异步获取的时候返回nil)
 */
- (UIImage *)imageWithAssert:(PHAsset *)assert synchronous:(BOOL)synchronous original:(BOOL)original complete:(void (^)(UIImage *image))complete;

@end
