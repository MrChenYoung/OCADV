//
//  RunloopController.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "RunloopController.h"
#import "RunloopModelController.h"
#import "RunloopLoadBigPicController.h"

/**
 * Runloop运行循环,保证线程不退出
 * 监听时钟、触摸、网络事件,没有事件处理就睡眠
 * 每条线程都有一个Runloop,主线程的Runloop在main函数的UIApplicationMain方法中被开启
 * 子线程的Runloop默认是不开启的,需要受到开启
 * Runloop
 */

@interface RunloopController ()<UITableViewDataSource,UITableViewDelegate>

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 列表数据
@property (nonatomic, strong) NSArray *listData;

@end

@implementation RunloopController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop用法";
    [self.view addSubview:self.tableView];
    
    self.listData = @[@"Runloop运行模式介绍",@"Runloop解决TableViewCell加载大图片卡顿"];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
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
    NSString *title = self.listData[indexPath.row];
    if ([title isEqualToString:@"Runloop运行模式介绍"]) {
        RunloopModelController *modelCtr = [[RunloopModelController alloc]init];
        [self.navigationController pushViewController:modelCtr animated:YES];
    }
    
    if ([title isEqualToString:@"Runloop解决TableViewCell加载大图片卡顿"]) {
        RunloopLoadBigPicController *ctr = [[RunloopLoadBigPicController alloc]init];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}



@end
