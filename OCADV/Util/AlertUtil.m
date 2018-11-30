//
//  AlertUtil.m
//  OCADV
//
//  Created by MrChen on 2018/11/30.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "AlertUtil.h"

@implementation AlertUtil

/**
 * 显示alert
 */
+ (void)showAlert:(NSString *)title msg:(NSString *)message inCtr:(UIViewController *)ctr
{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertCtr addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [ctr presentViewController:alertCtr animated:YES completion:nil];
}

@end
