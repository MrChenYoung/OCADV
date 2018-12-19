//
//  SocketClientOriginApiController.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketClientCoreFApiController.h"
#import "SocketCoreFoundationClient.h"

@interface SocketClientCoreFApiController ()

// 客户端socket1
@property (nonatomic, strong) SocketCoreFoundationClient *socketCoreClient;

@end

@implementation SocketClientCoreFApiController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 断开连接
    [self.socketCoreClient disConnect];
}

/**
* 初始化socket
*/
- (void)initSocket
{
    __weak typeof(self) weakSelf = self;
    // 客户端收到消息回调
    self.socketCoreClient = [[SocketCoreFoundationClient alloc]init];
    self.socketCoreClient.recMessageCallBack = ^(NSString * _Nonnull msg) {
        [weakSelf receiveMessage:msg];
    };
}

/**
 * 连接服务端
 */
- (void)connectionToServer:(NSString *)serverIP port:(NSInteger)port
{
    __weak typeof(self) weakSelf = self;
    [self showLoadingView:@"连接中..."];
    [self.socketCoreClient connectionToServer:serverIP port:port complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hiddenLoadingView];
            [weakSelf connetResultHandle:success];
        });
    }];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [super sendMessage:message];

    __weak typeof(self) weakSelf = self;
    
    // 发送消息
    [self showLoadingView:@"消息发送中..."];
    [self.socketCoreClient sendMessage:message result:^(BOOL success) {
        [weakSelf hiddenLoadingView];
        if (!success) {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"消息发送失败" inCtr:self];
        }
    }];
}

@end
