//
//  HYUploadImageModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/9.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, uploadStatus) {
    uploadStatusUnload, // 未上传过
    uploadStatusUploading, // 正在上传
    uploadStatusLoad    // 已上传过
};

@interface HYUploadImageModel : NSObject

// 图片对象
@property (nonatomic, strong) UIImage *image;

// 图片名字
@property (nonatomic, copy) NSString *imageName;

// 图片存在服务器的url
@property (nonatomic, copy) NSString *url;

// 上传时间戳
@property (nonatomic, assign) double uploadTimestamp;

// 上传的具体时间
@property (nonatomic, copy, readonly) NSString *uploadDate;

// 图片占用磁盘大小
@property (nonatomic, copy) NSString *imageLengthFormate;

// 图片索引
@property (nonatomic, assign) NSUInteger imageIndex;

// 上传进度
@property (nonatomic, assign) double progress;

// 图片存在服务器的id
@property (nonatomic, copy) NSString *media_id;

// 上传状态
@property (nonatomic, assign) uploadStatus status;

/**
 * 删除本地存储的图片信息
 */
- (void)deleteImageComplete:(void (^)(void))complete success:(void (^)(void))success faile:(void (^)(void))faile;

/**
 * 刷新image上传状态
 */
- (void)reloadImageStatus:(nullable void (^)(void))complete;

@end

NS_ASSUME_NONNULL_END
