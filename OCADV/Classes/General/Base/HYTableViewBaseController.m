//
//  HYMultiThreadBaseController.m
//  OCADV
//
//  Created by MrChen on 2018/12/21.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYTableViewBaseController.h"

@interface HYTableViewBaseController ()<UITableViewDataSource,UITableViewDelegate>

// tableView
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYTableViewBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.rowH = 44.0;
    
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self.view addSubview:_tableView];
    }
}

-(void)setData:(NSArray *)data
{
    _data = data;
    [self.tableView reloadData];
}

/**
 * 去掉tableView中间的线条
 */
- (void)removeTableViewSeperator
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

/**
 * 设置列表是否可以被点击
 */
- (void)setAllowSelection:(BOOL)allowSelection
{
    _allowSelection = allowSelection;
    self.tableView.allowsSelection = allowSelection;
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

// row height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowH;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self respondsToSelector:@selector(tableViewCell:indexPath:)]) {
        cell = [self tableViewCell:tableView indexPath:indexPath];
    }else {
        static NSString *reuserId = @"reuserId";
        cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
        if (cell == nil) {
            cell = [[HYTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuserId];
        }
        
        NSDictionary *dic = self.data[indexPath.row];
        cell.textLabel.text = dic[CELLTITLE];
        cell.detailTextLabel.text = dic[CELLDESCRIPTION];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.data[indexPath.row];
    NSString *className = dic[CONTROLLERNAME];
    NSString *title = dic[CELLTITLE];
    UIViewController *ctr = [[NSClassFromString(className) alloc]init];
    ctr.title = title;
    [self.navigationController pushViewController:ctr animated:YES];
}

@end
