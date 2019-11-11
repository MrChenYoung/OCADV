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

// 显示状态
@property (nonatomic, assign, readonly, getter = isShow) BOOL show;

// 选择的城市改变
@property (nonatomic, copy) void (^selectCityChangedBlock)(NSString *provence,NSString *city,NSString *distribute,NSInteger index);

/**
 * 显示/隐藏列表
 */
- (void)updateShowStateComplete:(void(^)(BOOL isShow))complete;

@end

NS_ASSUME_NONNULL_END
