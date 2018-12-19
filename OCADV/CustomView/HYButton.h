//
//  MyButton.h
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYButton : UIButton

// 按钮的y坐标
@property (nonatomic, assign) CGFloat btnY;

// 按钮的标题
@property (nonatomic, copy) NSString *titleText;

// 是否可以点击
@property (nonatomic, assign) BOOL clickAble;

/**
 * 显示等待loadingView
 */
- (void)showLoadingView:(NSString *)loadingText;

/**
 * 隐藏loadingView
 */
- (void)hiddenLoadingView;

@end

NS_ASSUME_NONNULL_END
