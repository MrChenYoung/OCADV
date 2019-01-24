//
//  HYVideiListViewController.h
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYVideiListViewController : HYBaseViewController

// 视频数据存储
@property (nonatomic, strong) NSArray <HYBaseVideoModel *>*videosData;

// 视频来源
@property (nonatomic, copy) NSString *videoSource;

@end

NS_ASSUME_NONNULL_END
