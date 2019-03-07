//
//  HYCheckVideoOrImageBaseCtr.h
//  OCADV
//
//  Created by MrChen on 2019/1/15.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPresentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYCheckImageBaseCtr : HYPresentViewController

// 查看的图片model
@property (nonatomic, weak) HYUploadImageModel *imageModel;

// 刷新accessToken回调
@property (nonatomic, copy) void (^requestAccessTokenBlock)(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void));

// 从服务器请求图片回调
@property (nonatomic, copy) void (^loadImageBlock)(NSString *urlString,void (^success)(NSData *response), void (^faile)(void));

// 删除图片请求回调
@property (nonatomic, copy) void (^deleteImageBlock)(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void));

@end

NS_ASSUME_NONNULL_END
