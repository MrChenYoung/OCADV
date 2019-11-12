//
//  HYMainView.h
//  OCADV
//
//  Created by MrChen on 2019/3/2.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYWeatherView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYMainView : UIView

// 查询天气view
@property (nonatomic, strong) HYWeatherView *weatherView;

@end

NS_ASSUME_NONNULL_END
