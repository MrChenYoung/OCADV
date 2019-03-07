//
//  HYWeatherCitiesModel.m
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYWeatherCitiesModel.h"

@implementation HYWeatherCitiesModel

/**
 * 异步获取城市数据
 */
- (void)loadCitiesAsynSuccess:(void (^)(NSArray *cities))success faile:(void (^)(NSString *errMessage))faile
{
    NSDictionary *parameters = @{@"key":JHAppKey};
    [HYURLConnectionUtil GET:WeatherSupportCitiesUrl headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
        // 转json
        if (result) {
            NSError *error = nil;
            NSDictionary *citiesDic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
            if (!citiesDic || error) {
                // 转换失败
                [self faileHandleWithErrorMessage:@"数据转换失败" faileBlock:faile];
            }else {
                // 转换成功,数据处理
                NSInteger resultCode = [citiesDic[@"resultcode"] integerValue];
                if (resultCode == 200) {
                    // 请求成功
                    NSMutableArray *citiesArrayM = [NSMutableArray array];
                    NSArray *citiesArray = citiesDic[@"result"];
                    for (NSDictionary *cityDic in citiesArray) {
                        HYWeatherCityModel *model = [HYWeatherCityModel yy_modelWithDictionary:cityDic];
                        [citiesArrayM addObject:model];
                    }
                    
                    self.cities = [citiesArrayM copy];
                    if (success) {
                        success(self.cities);
                    }
                }else {
                    // 请求失败
                    [self faileHandleWithErrorMessage:@"城市列表请求失败" faileBlock:faile];
                }
            }
        }else {
            [self faileHandleWithErrorMessage:@"查询结果为空" faileBlock:faile];
        }

    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
        [self faileHandleWithErrorMessage:@"请求失败" faileBlock:faile];
    }];
}

/**
 * 请求失败/数据处理出错处理
 */
- (void)faileHandleWithErrorMessage:(NSString *)errMessage faileBlock:(void (^)(NSString *message))faileBlock
{
    if (faileBlock) {
        if (errMessage.length > 0) {
            faileBlock(errMessage);
        }else {
            faileBlock(@"未知错误");
        }
    }
}

@end
