//
//  SocketServerCoreFApiController.m
//  OCADV
//
//  Created by MrChen on 2018/12/8.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketServerCoreFApiController.h"
#import "SocketCoreFoundationServer.h"

@interface SocketServerCoreFApiController ()

// 服务端socket
@property (nonatomic, strong) SocketCoreFoundationServer *socketServer;
@end

@implementation SocketServerCoreFApiController

- (void)viewDidLoad {
    [super viewDidLoad];

}

/**
 * 初始化socket
 */
- (void)initServerSocket
{
    __weak typeof(self) weakSelf = self;
    self.socketServer = [[SocketCoreFoundationServer alloc]init];
    // 收到客户端发送的消息回调
    self.socketServer.recMessageCallBack = ^(NSString * _Nonnull message) {
        [weakSelf recMessage:message];
    };
    
    // 有新的客户端连接回调
    self.socketServer.newClientConnectCallBack = ^(SocketClientModel * _Nonnull newClientModel, NSInteger connectedCount) {
        [weakSelf newClientConnect:[NSString stringWithFormat:@"%@:%ld",newClientModel.ipAddress,newClientModel.port] clientCount:connectedCount];
    };
    
    // 客户端断开连接
    self.socketServer.clientDisconnectionCallBack = ^(SocketClientModel * _Nonnull newClientModel, NSInteger connectedCount) {
        [weakSelf clientDisconnect:[NSString stringWithFormat:@"%@:%ld",newClientModel.ipAddress,newClientModel.port] clientCount:connectedCount];
    };
}

/**
 * 开启监听指定端口
 */
- (void)startListen:(NSInteger)port
{
    __weak typeof(self) weakSelf = self;
    [self.socketServer startListenPort:port result:^(BOOL success) {
        [weakSelf startListenResultHandle:success];
    }];
}

/**
 * 停止监听(关闭服务器)
 */
- (void)stopListen
{
    [super stopListen];
    
    [self.socketServer stopListen];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [self.socketServer sendBroadcastMessage:message];
}

@end
