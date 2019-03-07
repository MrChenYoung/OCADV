//
//  HYPthreadSingleFileController.m
//  OCADV
//
//  Created by MrChen on 2018/12/21.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYPthreadSingleFileController.h"
#import "HYDownloadSingleFileCell.h"

@interface HYPthreadSingleFileController ()

@end

@implementation HYPthreadSingleFileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rowH = 120.0;
    self.allowSelection = NO;
    [self removeTableViewSeperator];
}

- (UITableViewCell *)tableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"reuseId";
    HYDownloadSingleFileCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[HYDownloadSingleFileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    cell.model = self.data[indexPath.row];
    return cell;
}

@end
