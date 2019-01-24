//
//  HYPresentViewController.m
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYPresentViewController.h"
#import "HYTransitionAnimation.h"

@interface HYPresentViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation HYPresentViewController

// 自定义转场动画需设置代理
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [HYTransitionAnimation transitionWithTransitionType:TransitionAnimationTypePresent fromReact:self.fromReact];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [HYTransitionAnimation transitionWithTransitionType:TransitionAnimationTypeDismiss fromReact:self.fromReact];
}

@end
