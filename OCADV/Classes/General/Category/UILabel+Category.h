//
//  UITextView+Category.h
//  OCADV
//
//  Created by MrChen on 2019/3/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (Category)

/**
 * 设置label文字包含多种颜色和大小
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray colors:(NSArray<UIColor *> *)colorArray fontSizes:(NSArray *)fontArray;

/**
 * 设置label文字包含多种颜色
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray colors:(NSArray<UIColor *> *)colorArray;

/**
 * 设置label文字包含多种大小
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray fontSizes:(NSArray *)fontArray;
@end

NS_ASSUME_NONNULL_END
