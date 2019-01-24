//
//  NSString+Category.m
//  Deppon
//
//  Created by MrChen on 2017/12/1.
//  Copyright © 2017年 MrChen. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Category)

/**
 * 判断字符串是否是空
 * str 指定字符串
 */
+ (BOOL)emptyString:(NSString *)str
{
    if ([str isEqual:[NSNull null]] || [str isKindOfClass:[NSNull class]] || str == nil || [str isEqualToString:@"NULL"] || str.length == 0) {
        return YES;
    }else{
        return NO;
    }
}

/**
 * 判断字符串是否全部是空格
 */
- (BOOL)spaceString
{
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }else {
        return NO;
    }
}


/**
 * 除去字符串中指定的字符
 * willRepString 被替换的字符
 * newString 替换的字符
 */
- (NSString *)replaceSubString:(NSString *)willRepString withString:(NSString *)newString
{
    return [self stringByReplacingOccurrencesOfString:willRepString withString:newString];
}

/**
 * 将字符串以空格隔开
 * byteNum:多少个字符分割一次
 */
- (NSString *)completionByBlank:(int)byteNum
{
    NSString *result = @"";
    NSString *remaindStr = self;
    int i = byteNum;
    
    while (1) {
        NSString *str = remaindStr.length >= byteNum ? [remaindStr substringToIndex:byteNum] : remaindStr;
        remaindStr = i <= self.length ? [self substringFromIndex:i] : @"";
        
        if (str.length == byteNum) {
            str = [str stringByAppendingString:@" "];
        }
        result = [result stringByAppendingString:str];
        
        if (!remaindStr.length) {
            break;
        }
        
        i += byteNum;
    }
    
    return result;
}

/**
 *  计算字符串的size
 *
 *  @param font    字体
 *  @param maxSize 最大size
 *
 *  @return 计算结果size
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *atribut = @{NSFontAttributeName : font};
    CGRect rect = [self boundingRectWithSize:maxSize
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:atribut
                                     context:nil];
    CGSize size = CGSizeMake(rect.size.width + 1, rect.size.height);
    return size;
}

#pragma mark - json和字符串互转
/**
 *  json字符串转换成json
 *
 *  @return json
 */
- (id)toJsonData
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if(err) {
        return nil;
    }else{
        return result;
    }
}

/**
 * json对象转换成字符串
 * object json(字典/数组)
 */
+ (NSString *)jsonObjectToString: (id)object
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    if (error) {
        return nil;
    }else {
        return str;
    }
}

#pragma mark - UTF8编解码
/**
 * UTF8编码
 */
- (NSString *)utf8Encode
{
    CGFloat iosVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iosVersion >= 9.0) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }else {
        return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

/**
 * UTF8解码
 */
- (NSString *)utf8Decode
{
    CGFloat iosVersion = [[UIDevice currentDevice].systemVersion floatValue];
    if (iosVersion >= 9.0) {
        return [self stringByRemovingPercentEncoding];
    }else {
        return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

#pragma mark - MD5加密
/**
 * 对字符串进行md5加密
 */
- (NSString *)md5Encode
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
