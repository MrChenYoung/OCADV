//
//  HYM3u8DownloadCell.h
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYM3u8FileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYM3u8DownloadCell : UITableViewCell

// 数据模型
@property (nonatomic, strong) HYM3u8FileModel *model;

// 开始下载回调
@property (nonatomic, copy) void (^startDownloadBlock)(HYM3u8FileModel *model);

@end

NS_ASSUME_NONNULL_END
