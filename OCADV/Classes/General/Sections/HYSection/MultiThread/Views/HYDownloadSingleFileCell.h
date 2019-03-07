//
//  HYDownloadSingleFileCell.h
//  OCADV
//
//  Created by MrChen on 2018/12/21.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYDownloadFileModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYDownloadSingleFileCell : UITableViewCell

// 模型
@property (nonatomic, strong) HYDownloadFileModel *model;

@end

NS_ASSUME_NONNULL_END
