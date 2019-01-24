//
//  NSString+Category.h
//  Deppon
//
//  Created by MrChen on 2017/12/1.
//  Copyright © 2017年 MrChen. All rights reserved.
//

/**
 * 功能列表
 * 1> 判断字符串是否为空
 * 2> 判断字符串是否全部为空格
 * 3> 替换字符串中的指定字符
 * 4> 将字符串在指定位数以空格隔开
 * 5> 计算字符串的size
 * 6> json和字符串互转
 * 7> 字符串的UTF8编解码
 * 8> 字符串的MD5加密
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 * 判断字符串是否是空
 * str 指定字符串
 */
+ (BOOL)emptyString:(NSString *)str;

/**
 * 判断字符串是否全部是空格
 */
- (BOOL)spaceString;

/**
 * 除去字符串中指定的字符
 * willRepString 被替换的字符
 * newString 替换的字符
 */
- (NSString *)replaceSubString:(NSString *)willRepString withString:(NSString *)newString;

/**
 * 将字符串以空格隔开
 * byteNum:多少个字符分割一次
 */
- (NSString *)completionByBlank:(int)byteNum;

/**
 *  计算字符串的size
 *
 *  @param font    字体
 *  @param maxSize 最大size
 *
 *  @return 计算结果size
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

#pragma mark - json和字符串互转
/**
 *  json字符串转换成json
 *
 *  @return json
 */
- (id)toJsonData;

/**
 * json对象转换成字符串
 * object json(字典/数组)
 */
+ (NSString *)jsonObjectToString: (id)object;


#pragma mark - UTF8编解码
/**
 * UTF8编码
 */
- (NSString *)utf8Encode;


/**
 * UTF8解码
 */
- (NSString *)utf8Decode;

#pragma mark - MD5加密
/**
 * 对字符串进行md5加密
 */
- (NSString *)md5Encode;

@end
