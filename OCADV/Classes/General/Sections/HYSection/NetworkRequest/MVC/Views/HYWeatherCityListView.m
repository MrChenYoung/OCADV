//
//  HYWeatherCityListView.m
//  OCADV
//
//  Created by MrChen on 2019/3/7.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYWeatherCityListView.h"

#define CellRowH 40.0

@interface HYWeatherCityListView ()<UITableViewDataSource,UITableViewDelegate>

// 显示状态
@property (nonatomic, assign, readwrite, getter = isShow) BOOL show;

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 高度
@property (nonatomic, assign) CGFloat height;

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
    
    // 计算高度
    CGFloat height = cityDatas.count * CellRowH;
    height = height > self.maxHeight ? self.maxHeight : height;
    self.height = height;
    
    [self.tableView reloadData];
}

#pragma mark - custom method
/**
 * 显示/隐藏列表
 */
- (void)updateShowStateComplete:(void(^)(BOOL isShow))complete
{
    [UIView animateWithDuration:0.3 animations:^{
        if (!self.isShow) {
            self.viewHeight = self.height;
            self.tableView.viewHeight = self.height;
        }else {
            self.viewHeight = 0.0;
            self.tableView.viewHeight = 0.0;
        }
    }completion:^(BOOL finished) {
        self.show = !self.isShow;
        
        if (complete) {
            complete(self.isShow);
        }
    }];
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
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    NSString *cityString = self.cityDatas[indexPath.row];
    NSArray *cityInfo = [cityString componentsSeparatedByString:@"-"];
    [cell.textLabel setAttributedTitleWithStrings:cityInfo colors:@[ColorDefaultText,ColorGrayText,ColorLightGrayText] fontSizes:@[@14,@12,@10]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellRowH;
}

// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self updateShowStateComplete:^(BOOL isShow) {
        if (self.selectCityChangedBlock) {
            NSString *cityString = self.cityDatas[indexPath.row];
            NSArray *cityInfo = [cityString componentsSeparatedByString:@"-"];
            NSString *provence = cityInfo.count >= 1 ? cityInfo.firstObject : @"";
            NSString *city = cityInfo.count >= 2 ? cityInfo[1] : @"";
            NSString *distribute = cityInfo.count >= 3 ? cityInfo[2] : @"";
            self.selectCityChangedBlock(provence,city,distribute,indexPath.row);
        }
    }];
}
@end
