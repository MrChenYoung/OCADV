//
//  HYVideoCategoryModel.h
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYVideoCategoryModel : NSObject

// 视频模型
@property (nonatomic, weak) NSArray <HYBaseVideoModel *>*videos;

@end

NS_ASSUME_NONNULL_END
