//
//  HYWeatherCityModel.h
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYWeatherCityModel : NSObject

// id
@property (nonatomic, copy) NSString *cityId;

// 省
@property (nonatomic, copy) NSString *province;

// 市
@property (nonatomic, copy) NSString *city;

// 区
@property (nonatomic, copy) NSString *district;

// 地区字符串
@property (nonatomic, copy) NSString *cityString;

@end

NS_ASSUME_NONNULL_END
