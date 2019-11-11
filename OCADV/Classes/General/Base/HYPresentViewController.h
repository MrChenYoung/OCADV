//
//  HYPresentViewController.h
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYPresentViewController : UIViewController

// 动画开始的时候的位置和大小
@property (nonatomic, assign) CGRect fromReact;

// 界面消失以后回调
@property (nonatomic, copy) void (^dismissComplete)(BOOL deleteVideo);

@end

NS_ASSUME_NONNULL_END
