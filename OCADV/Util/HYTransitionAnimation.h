//
//  XWCircleSpreadTransition.h
//  XWTrasitionPractice
//
//  Created by YouLoft_MacMini on 15/11/25.
//  Copyright © 2015年 YouLoft_MacMini. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TransitionAnimationType) {
    TransitionAnimationTypePresent = 0,
    TransitionAnimationTypeDismiss
};

@interface HYTransitionAnimation : NSObject<UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

@property (nonatomic, assign) TransitionAnimationType type;
@property (nonatomic, assign) CGRect fromReact;

+ (instancetype)transitionWithTransitionType:(TransitionAnimationType)type fromReact:(CGRect)fromReact;
- (instancetype)initWithTransitionType:(TransitionAnimationType)type fromReact:(CGRect)fromReact;
@end
