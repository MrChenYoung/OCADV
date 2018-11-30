//
//  AppDelegate.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
// 底部提示框
@property (nonatomic, strong) UITextView *bottomTextView;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *mainVc = [[ViewController alloc]init];
    UINavigationController *navCtr = [[UINavigationController alloc]initWithRootViewController:mainVc];
    self.window.rootViewController = navCtr;
    [self.window makeKeyAndVisible];
    
    // 底部提示框
    CGFloat h = 35;
    _bottomTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, -h, ScWidth, h)];
    _bottomTextView.backgroundColor = [UIColor orangeColor];
    _bottomTextView.textAlignment = NSTextAlignmentCenter;
    [self.window addSubview:_bottomTextView];
    
    // 隐藏状态栏
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/**
 * 显示底部提示文字
 */
- (void)showBottomTextView:(NSString *)message
{
    [self showBottomTextView:message complete:nil];
}

/**
 * 显示底部l文字，2秒后隐藏
 */
- (void)showBottomTextViewDelay:(NSString *)message
{
    [self showBottomTextView:message complete:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hiddenBottomTextView];
        });
    }];
}

/**
 * 显示底部文字
 */
- (void)showBottomTextView:(NSString *)message complete:(void(^)(void))complete
{
    self.bottomTextView.text = message;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomTextView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bottomTextView.frame));
    }completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
}

/**
 * 隐藏底部文字
 */
- (void)hiddenBottomTextView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomTextView.transform = CGAffineTransformIdentity;
    }];
}

/**
 * 设置底部文字
 */
- (void)updateBottomTextView:(NSString *)text
{
    self.bottomTextView.text = text;
}




@end
