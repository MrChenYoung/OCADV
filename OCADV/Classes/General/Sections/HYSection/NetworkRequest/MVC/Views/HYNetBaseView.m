//
//  HYNetBaseView.m
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYNetBaseView.h"

@implementation HYNetBaseView

/**
 * 创建模块标题label
 */
- (UILabel *)createModuleTitleLabelOrigin:(CGPoint)origin text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(origin.x, origin.y, self.bounds.size.width - 5.0, 30.0)];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.text = text;
    return label;
}

@end
