//
//  NSData+Category.m
//  OCADV
//
//  Created by MrChen on 2018/12/26.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "NSData+Category.h"

@implementation NSData (Category)

/**
 * NSData转换成NSString
 */
- (NSString *)toString
{
    NSString *str = nil;
    // 先按照UTF8解码
    str = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];

    if (str == nil) {
        // 用GBK解码
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        str = [[NSString alloc]initWithData:self encoding:gbkEncoding];
    }
    
    if (str == nil) {
        // 如果这个data数据不是以\0结尾
        str = [[NSString alloc]initWithData:self encoding:NSASCIIStringEncoding];
    }
    
    if (str == nil) {
        // 如果data是以\0结尾的，例如是从c字符串转换过来的，那就要换下面这种方法了，这样可以避免把最后的\0也转换到NSString里面
        str = [NSString stringWithUTF8String:[self bytes]];
    }

    return str;
}

@end
