//
//  MultiThreadMainController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYMultiThreadMainController.h"

@interface HYMultiThreadMainController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *data;
@end

@implementation HYMultiThreadMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iOS多线程开发";
    self.data = @[@{CELLTITLE:@"pthread",
                    CELLDESCRIPTION:@"跨平台的多线程开发框架",
                    CONTROLLERNAME:@"PthreadController"},
                  @{CELLTITLE:@"NSThread",
                    CELLDESCRIPTION:@"苹果原生封装框架",
                    CONTROLLERNAME:@"NSThreadController"},
                  ];
    
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
    HYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
    }
    
    NSDictionary *dic = self.data[indexPath.row];
    cell.textLabel.text = dic[CELLTITLE];
    cell.detailTextLabel.text = dic[CELLDESCRIPTION];
    return cell;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.data[indexPath.row];
    NSString *ctrName = dic[CONTROLLERNAME];
    UIViewController *ctr = [[NSClassFromString(ctrName) alloc]init];
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
