//
//  HYDownloadSingleFileCell.m
//  OCADV
//
//  Created by MrChen on 2018/12/21.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYDownloadSingleFileCell.h"

@interface HYDownloadSingleFileCell ()

// 主视图
@property (nonatomic, strong) HYDownloadView *mainView;

@end

@implementation HYDownloadSingleFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 创建子视图
        [self createSubViews];
    }
    
    return self;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    CGRect frame = self.frame;
    frame.size.height = 120.0;
    self.frame = frame;
    CGFloat padding = 5.0;
    self.mainView = [[HYDownloadView alloc]initWithFrame:CGRectMake(padding, padding, ScWidth - padding * 2.0, frame.size.height - padding)];
    [self.contentView addSubview:self.mainView];
}

// 绑定数据
- (void)setModel:(HYDownloadFileModel *)model
{
    _model = model;
    self.mainView.model = model;
}

@end
