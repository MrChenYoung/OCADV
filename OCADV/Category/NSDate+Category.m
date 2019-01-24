//
//  NSDate+Category.m
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)

/**
 * 秒格式换成时分秒
 * 要格式化的总秒数
 */
+ (NSString *)timeFormat:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}
@end
