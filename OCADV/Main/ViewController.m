//
//  ViewController.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoaController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 列表数据
@property (nonatomic, strong) NSArray *listData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iOS高级开发";
    
    // 添加列表
    [self.view addSubview:self.tableView];
    
    // 初始化列表数据
    self.listData = @[@"ReactiveCocoa(RAC)"];
}

/**
 * 懒加载tableView
 */
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}


#pragma mark - UITableViewDataSource

// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    cell.textLabel.text = self.listData[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 跳转到指定页面
    NSString *selectTitle = self.listData[indexPath.row];
    if ([selectTitle isEqualToString:@"ReactiveCocoa(RAC)"]) {
        // RAC页面
        ReactiveCocoaController *racCtr = [[ReactiveCocoaController alloc]init];
        [self.navigationController pushViewController:racCtr animated:YES];
    }
    
}


@end
