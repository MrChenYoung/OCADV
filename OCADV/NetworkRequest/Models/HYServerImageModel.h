//
//  HYServerImageModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/16.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYServerImageModel : NSObject

// 图片id
@property (nonatomic, copy) NSString *media_id;

// 图片名字
@property (nonatomic, copy) NSString *name;

// 更新时间戳
@property (nonatomic, assign) double update_time;

// 图片url
@property (nonatomic, copy) NSString *url;


+ (instancetype)imageModelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
