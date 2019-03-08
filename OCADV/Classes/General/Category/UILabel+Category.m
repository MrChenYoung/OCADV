//
//  UITextView+Category.m
//  OCADV
//
//  Created by MrChen on 2019/3/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "UILabel+Category.h"

@implementation UILabel (Category)

/**
 * 设置label文字包含多种颜色和大小
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray colors:(NSArray<UIColor *> *)colorArray fontSizes:(NSArray *)fontArray
{
    NSMutableAttributedString *mutAttStr = [[NSMutableAttributedString alloc] init];
    
    for (int i = 0; i < strArray.count; i++) {
        NSString *str = strArray[i];
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        
        // 改变颜色
        if (colorArray == nil || colorArray.count == 0) {
            [attributes setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        }else if (colorArray.count >= (i+1)) {
            [attributes setObject:colorArray[i] forKey:NSForegroundColorAttributeName];
        }else {
            [attributes setObject:colorArray.firstObject forKey:NSForegroundColorAttributeName];
        }
        
        // 改变字体大小
        if (fontArray == nil || fontArray.count == 0) {
            [attributes setObject:[UIFont systemFontOfSize:14.0] forKey:NSFontAttributeName];
        }else if (fontArray.count >= (i+1)) {
            UIFont *font = [UIFont systemFontOfSize:[fontArray[i] floatValue]];
            [attributes setObject:font forKey:NSFontAttributeName];
        }else {
            UIFont *font = [UIFont systemFontOfSize:[fontArray.firstObject floatValue]];
            [attributes setObject:font forKey:NSFontAttributeName];
        }
        
        NSAttributedString *attributString = [[NSAttributedString alloc]initWithString:str attributes:attributes];
        [mutAttStr appendAttributedString:attributString];
    }
    
    [self setAttributedText:mutAttStr];
}

/**
 * 设置label文字包含多种颜色
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray colors:(NSArray<UIColor *> *)colorArray
{
    [self setAttributedTitleWithStrings:strArray colors:colorArray fontSizes:nil];
}


/**
 * 设置label文字包含多种大小
 */
- (void)setAttributedTitleWithStrings:(NSArray<NSString *> *)strArray fontSizes:(NSArray *)fontArray
{
    [self setAttributedTitleWithStrings:strArray colors:nil fontSizes:fontArray];
}

@end
