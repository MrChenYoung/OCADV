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
    uploadStatusLoad    // 已上传过
};

@interface HYUploadImageModel : NSObject

// 图片对象
@property (nonatomic, strong) UIImage *image;

// 图片名字
@property (nonatomic, copy) NSString *imageName;

// 图片索引
@property (nonatomic, assign) NSUInteger imageIndex;

// 图片存在服务器的路径
@property (nonatomic, copy) NSString *remoteUrl;

// 上传状态
@property (nonatomic, assign) uploadStatus status;

@end

NS_ASSUME_NONNULL_END
