//
//  HYWeatherView.h
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYNetBaseView.h"
#import "HYWeatherCityListView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYWeatherView : HYNetBaseView

// 选中的省
@property (nonatomic, copy) NSString *selectProvence;

// 选中的市
@property (nonatomic, copy) NSString *selectCity;

// 选中的区
@property (nonatomic, copy) NSString *selectDistrict;

// 选择的城市改变
@property (nonatomic, copy) void (^selectCityChangedBlock)(NSInteger index);

// 城市列表
@property (nonatomic, strong) HYWeatherCityListView *cityListView;


@end

NS_ASSUME_NONNULL_END
