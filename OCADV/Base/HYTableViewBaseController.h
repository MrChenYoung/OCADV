//
//  HYMultiThreadBaseController.h
//  OCADV
//
//  Created by MrChen on 2018/12/21.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYTableViewBaseController : UIViewController

// 数据
@property (nonatomic, strong) NSArray *data;

// 行高
@property (nonatomic, assign) CGFloat rowH;

// 是否允许点击
@property (nonatomic, assign) BOOL allowSelection;

/**
 * 去掉tableView中间的线条
 */
- (void)removeTableViewSeperator;

/**
 * 获取tableViewCell 子类如果要自定义自己的cell的话要实现该方法
 */
- (UITableViewCell *)tableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
