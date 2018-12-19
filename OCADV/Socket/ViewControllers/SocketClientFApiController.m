//
//  SocketClientFApiController.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketClientFApiController.h"
#import "SocketFoundationClient.h"

@interface SocketClientFApiController ()
// socket
@property (nonatomic, strong) SocketFoundationClient *socketFClient;

@end

@implementation SocketClientFApiController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 断开连接
    [self.socketFClient disConnect];
}

/**
 * 初始化socket
 */
- (void)initSocket
{
    __weak typeof(self) weakSelf = self;
    self.socketFClient = [[SocketFoundationClient alloc]init];
    self.socketFClient.recMessageCallBack = ^(NSString * _Nonnull msg) {
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
    [self.socketFClient connectionToServer:serverIP port:port complete:^(BOOL success) {
        [weakSelf hiddenLoadingView];
        [weakSelf connetResultHandle:success];
    }];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [super sendMessage:message];
    [self showLoadingView:@"发送中..."];
    __weak typeof(self) weakSelf = self;
    [self.socketFClient sendMessage:message result:^(BOOL success) {
        [weakSelf hiddenLoadingView];
        if (!success) {
            // 发送失败
            [HYAlertUtil showAlertTitle:@"提示" msg:@"消息发送失败" inCtr:weakSelf];
        }
    }];
}

@end
