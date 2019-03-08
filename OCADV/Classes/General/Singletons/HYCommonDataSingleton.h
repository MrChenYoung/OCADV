//
//  HYCommonDataSingleton.h
//  OCADV
//
//  Created by MrChen on 2019/3/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYCommonDataSingleton : NSObject

// 城市数据
@property (nonatomic, copy) NSArray *weatherCities;

+ (instancetype)share;

@end

NS_ASSUME_NONNULL_END
