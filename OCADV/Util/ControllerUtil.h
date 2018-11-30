//
//  ControllerUtil.h
//  OCADV
//
//  Created by MrChen on 2018/11/30.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ControllerUtil : NSObject

/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
