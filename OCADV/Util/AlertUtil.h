//
//  AlertUtil.h
//  OCADV
//
//  Created by MrChen on 2018/11/30.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertUtil : NSObject

/**
 * 显示alert
 */
+ (void)showAlert:(NSString *)title msg:(NSString *)message inCtr:(UIViewController *)ctr;

@end

NS_ASSUME_NONNULL_END
