//
//  HYWeatherCitiesModel.h
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYWeatherCityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYWeatherCitiesModel : NSObject

// 城市列表
@property (nonatomic, copy) NSArray<HYWeatherCityModel*> *cities;

/**
 * 异步获取城市数据
 */
- (void)loadCitiesAsynSuccess:(void (^)(NSArray *cities))success faile:(void (^)(NSString *errMessage))faile;

@end

NS_ASSUME_NONNULL_END
