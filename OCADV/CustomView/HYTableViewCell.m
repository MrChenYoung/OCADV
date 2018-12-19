//
//  MyTableViewCell.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYTableViewCell.h"

@implementation HYTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initailCell];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initailCell];
}

- (void)initailCell
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.detailTextLabel.textColor = [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1.0];
}

@end
