//
//  HYMovieThumbnailImageListCell.m
//  OCADV
//
//  Created by MrChen on 2019/1/20.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoThumbnailListCell.h"

@implementation HYVideoThumbnailListCell

#pragma mark - custom method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self startLoading];
    return self;
}

/**
 * 开始加载
 */
- (void)startLoading
{
    [self.loadingView startAnimating];
}

/**
 * 停止加载
 */
- (void)stopLoading
{
    [self.loadingView stopAnimating];
}

#pragma mark - setter
/**
 * 绑定数据
 */
- (void)setModel:(HYNormalVideoModel *)model
{
    [super setModel:model];
    
    [self updateSubViewFrame];
    
    // 设置自己的menumBgView样式
    CGRect menumBgFrame = self.menuBgView.frame;
    menumBgFrame.size.height = 20.0;
    menumBgFrame.origin.y = model.naturalSize.height - 20.0;
    self.menuBgView.frame = menumBgFrame;

    // 设置当前时间显示框
    self.videoLengthLabel.center = CGPointMake(self.videoLengthLabel.center.x, self.menuBgView.bounds.size.height * 0.5);
}

@end
