//
//  ControllerUtil.m
//  OCADV
//
//  Created by MrChen on 2018/11/30.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "ControllerUtil.h"

@implementation ControllerUtil

/**
 * 获取当前显示的控制器
 */
+ (UIViewController *)topViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self topViewControllerWithRootController:rootViewController];
}

// 获取当前显示的控制器
+ (UIViewController *)topViewControllerWithRootController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
