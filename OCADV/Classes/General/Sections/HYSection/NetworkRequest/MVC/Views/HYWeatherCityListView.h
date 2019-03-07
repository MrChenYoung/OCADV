//
//  HYWeatherCityListView.h
//  OCADV
//
//  Created by MrChen on 2019/3/7.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYWeatherCityListView : UIView

// 最大高度
@property (nonatomic, assign) CGFloat maxHeight;

// 城市数据
@property (nonatomic, copy) NSArray<NSString *> *cityDatas;

@end

NS_ASSUME_NONNULL_END
