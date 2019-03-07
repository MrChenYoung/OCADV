//
//  RunloopLoadBigPicController.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "RunloopLoadBigPicController.h"

@interface RunloopLoadBigPicController ()

// 列表
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation RunloopLoadBigPicController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop解决TableView卡顿问题";
    
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
// section number
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return <#cell#>;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

@end
