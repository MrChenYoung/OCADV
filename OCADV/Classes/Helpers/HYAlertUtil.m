//
//  AlertUtil.m
//  OCADV
//
//  Created by MrChen on 2018/11/30.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYAlertUtil.h"

@implementation HYAlertUtil

/**
 * 显示alert
 */
+ (void)showAlertTitle:(NSString *)title msg:(NSString *)message inCtr:(UIViewController *)ctr
{
    __block UIViewController *parentCtr = ctr;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (parentCtr == nil) {
            parentCtr = [UIApplication sharedApplication].keyWindow.rootViewController;
        }
        
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertCtr addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [parentCtr presentViewController:alertCtr animated:YES completion:nil];
    });
}

@end
