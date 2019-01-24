//
//  UIImage+Category.h
//  OCADV
//
//  Created by MrChen on 2019/1/14.
//  Copyright © 2019 MrChen. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Category)

/**
 * 压缩图片到指定大小
 * toLength 希望压缩到的大小 单位b
 */
- (NSData *)compressToLength:(NSUInteger)toLength;

@end

NS_ASSUME_NONNULL_END
