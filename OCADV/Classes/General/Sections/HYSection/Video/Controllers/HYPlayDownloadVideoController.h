//
//  HYPlayDownloadVideoController.h
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPlayVideoBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYPlayDownloadVideoController : HYPlayVideoBaseController

// 视频下载model
@property (nonatomic, weak) HYDownloadFileModel *downloadMovieModel;

@end

NS_ASSUME_NONNULL_END
