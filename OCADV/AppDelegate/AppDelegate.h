//
//  AppDelegate.h
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


/**
 * 显示底部提示文字
 */
- (void)showBottomTextView:(NSString *)message;

/**
 * 显示底部l文字，2秒后隐藏
 */
- (void)showBottomTextViewDelay:(NSString *)message;

/**
 * 隐藏底部文字
 */
- (void)hiddenBottomTextView;

/**
 * 设置底部文字
 */
- (void)updateBottomTextView:(NSString *)text;

@end

