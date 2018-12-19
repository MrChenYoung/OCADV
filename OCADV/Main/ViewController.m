//
//  ViewController.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "ViewController.h"

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
    self.listData = @[@{CELLTITLE:@"ReactiveCocoa(RAC)",
                        CELLDESCRIPTION:@"函数响应式编程应用",
                        CONTROLLERNAME:@"ReactiveCocoaController"},
                      @{CELLTITLE:@"Runloop",
                        CELLDESCRIPTION:@"运行循环剖析",
                        CONTROLLERNAME:@"RunloopController"},
                      @{CELLTITLE:@"Socket",
                        CELLDESCRIPTION:@"即时通讯常用技术",
                        CONTROLLERNAME:@"SocketViewController"},
                      @{CELLTITLE:@"多线程",
                        CELLDESCRIPTION:@"iOS多线程开发常用技能",
                        CONTROLLERNAME:@"MultiThreadMainController"}
                      ];
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
    HYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
    }
    
    NSDictionary *dic = self.listData[indexPath.row];
    cell.textLabel.text = dic[CELLTITLE];
    cell.detailTextLabel.text = dic[CELLDESCRIPTION];
    return cell;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 跳转到指定页面
    NSDictionary *dic = self.listData[indexPath.row];
    NSString *controllerName = dic[CONTROLLERNAME];
    UIViewController *ctr = [[NSClassFromString(controllerName) alloc]init];
    [self.navigationController pushViewController:ctr animated:YES];
}


@end
