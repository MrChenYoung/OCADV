//
//  HYWeatherCityListView.m
//  OCADV
//
//  Created by MrChen on 2019/3/7.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYWeatherCityListView.h"

#define CellRowH 44.0

@interface HYWeatherCityListView ()<UITableViewDataSource,UITableViewDelegate>

// 列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYWeatherCityListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = ColorLightGray.CGColor;
    }
    return self;
}

#pragma mark - lazy loading
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

-(void)setCityDatas:(NSArray<NSString *> *)cityDatas
{
    _cityDatas = cityDatas;
    CGFloat height = cityDatas.count * CellRowH;
    height = height > self.maxHeight ? self.maxHeight : height;
    self.viewHeight = height;
    self.tableView.viewHeight = height;
    [self.tableView reloadData];
}

#pragma mark - custom method
/**
 * 显示
 */
- (void)show
{
    
}

/**
 * 隐藏
 */
- (void)hidden
{
    
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cityDatas.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    cell.textLabel.text = self.cityDatas[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
@end
