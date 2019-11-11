//
//  UIButton+Category.h
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Category)

/**
 * 设置按钮文字包含多种颜色和大小
 */
- (void)setAttributedTitleWithStrings:(nullable NSArray<NSString *> *)strArray colors:(nullable NSArray<UIColor *> *)colorArray fontSizes:(nullable NSArray *)fontArray;

/**
 * 设置按钮文字包含多种颜色
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray colors:(NSArray<UIColor *> *)colorArray;

/**
 * 设置按钮文字包含多种大小
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray fontSizes:(NSArray *)fontArray;

@end

NS_ASSUME_NONNULL_END
