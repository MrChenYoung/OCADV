//
//  SocketViewController.m
//  OCADV
//
//  Created by MrChen on 2018/12/5.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketViewController.h"
#import "SocketServerCoreFApiController.h"
#import "SocketServerCocoaAsyncController.h"
#import "SocketClientCoreFApiController.h"
#import "SocketClientFApiController.h"
#import "SocketClientCocoaAsyncController.h"
#import "SocketServerFApiController.h"
#import "SocketServerWebController.h"
#import "SocketClientWebController.h"

/**
 * 电脑终端模拟socket服务端和客户端命令(mac系统)
 * 开启服务端：
 *      nc -lk <端口号> 释:nc-->Netcat终端下用于调试和检查网络的工具
 * 模拟客户端连接服务端:
 *      nc <要连接到服务端的ip> <要连接到服务端的端口号>
 */

@interface SocketViewController ()<UITableViewDelegate,UITableViewDataSource>

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 列表数据
@property (nonatomic, strong) NSArray *listData;
@end

@implementation SocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Socket编程";
    self.listData = @[@{CELLTITLE:@"socket客户端",CELLDESCRIPTION:@"苹果CoreFoundation框架API实现"},
                      @{CELLTITLE:@"socket客户端",CELLDESCRIPTION:@"苹果Foundation框架API实现"},
                      @{CELLTITLE:@"socket客户端",CELLDESCRIPTION:@"CocoaAsyncSocket第三方框架实现"},
                      @{CELLTITLE:@"webSocket客户端",CELLDESCRIPTION:@"facebook开源框架SocketRocket实现"},
                      @{CELLTITLE:@"socket服务端",CELLDESCRIPTION:@"苹果CoreFoundation框架API实现"},
                      @{CELLTITLE:@"socket服务端",CELLDESCRIPTION:@"苹果Foundation框架API实现"},
                      @{CELLTITLE:@"socket服务端",CELLDESCRIPTION:@"CocoaAsyncSocket第三方框架实现"},
                      @{CELLTITLE:@"webSocket服务端",CELLDESCRIPTION:@"webSocket实现"}];
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
// section number
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
    
    switch (indexPath.row) {
        case 0:
        {
            // 苹果CoreFoundation框架API实现
            SocketClientCoreFApiController *clientCtr = [[SocketClientCoreFApiController alloc]init];
            [self.navigationController pushViewController:clientCtr animated:YES];
        }
            break;
        case 1:
        {
            // 苹果Foundation框架API实现
            SocketClientFApiController *fClientCtr = [[SocketClientFApiController alloc]init];
            [self.navigationController pushViewController:fClientCtr animated:YES];
            
        }
            break;
        case 2:
        {
            // CocoaAsyncSocket第三方框架实现socket客户端
            SocketClientCocoaAsyncController *cocaAsynCtr = [[SocketClientCocoaAsyncController alloc]init];
            [self.navigationController pushViewController:cocaAsynCtr animated:YES];
        }
            break;
        case 3:
        {
            // facebook开源框架SocketRocket实现webSocket客户端
            SocketClientWebController *ctr = [[SocketClientWebController alloc]init];
            [self.navigationController pushViewController:ctr animated:YES];
        }
            break;
        case 4:
        {
            // 苹果CoreFoundation框架API实现服务端
            SocketServerCoreFApiController *serverCtr = [[SocketServerCoreFApiController alloc]init];
            [self.navigationController pushViewController:serverCtr animated:YES];
        }
            break;
        case 5:
        {
            // 苹果Foundation框架API实现服务端
            SocketServerFApiController *ctr = [[SocketServerFApiController alloc]init];
            [self.navigationController pushViewController:ctr animated:YES];
        }
            break;
        case 6:
        {
            // CocoaAsyncSocket第三方框架实现服务端
            SocketServerCocoaAsyncController *serverCtr = [[SocketServerCocoaAsyncController alloc]init];
            [self.navigationController pushViewController:serverCtr animated:YES];
        }
            break;
        case 7:
        {
            // websocket 服务端
            SocketServerWebController *ctr = [[SocketServerWebController alloc]init];
            [self.navigationController pushViewController:ctr animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
