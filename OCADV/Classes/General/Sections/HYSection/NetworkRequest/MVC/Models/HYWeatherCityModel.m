//
//  HYWeatherCityModel.m
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYWeatherCityModel.h"

@implementation HYWeatherCityModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"cityId":@"id"};
}

- (NSString *)cityString
{
    NSString *str = self.province;
    
    if (self.city.length > 0 && ![self.province isEqualToString:self.city]) {
        str = [str stringByAppendingFormat:@"-%@",self.city];
    }
    
    if (self.district.length > 0 && ![self.city isEqualToString:self.district]) {
        str = [str stringByAppendingFormat:@"-%@",self.district];
    }
    
    return str;
}

@end
