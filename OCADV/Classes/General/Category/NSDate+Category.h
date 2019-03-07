//
//  NSDate+Category.h
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Category)

/**
 * 秒格式换成时分秒
 * 要格式化的总秒数
 */
+ (NSString *)timeFormat:(NSInteger)seconds;

@end

NS_ASSUME_NONNULL_END
