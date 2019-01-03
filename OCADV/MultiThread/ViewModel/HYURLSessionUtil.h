//
//  HYURLSessionUtil.h
//  Test4iOS
//
//  Created by MrChen on 2018/12/20.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYURLSessionUtil : NSObject

/**
 * 开始下载文件资源
 */
- (void)downloadWithUrl:(NSString *)url savePath:(NSString *)savePath;

@end

NS_ASSUME_NONNULL_END
