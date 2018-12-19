//
//  SocketServerCocoaAsyncController.m
//  OCADV
//
//  Created by MrChen on 2018/12/8.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketServerCocoaAsyncController.h"
#import "SocketCocoaAsynServer.h"

@interface SocketServerCocoaAsyncController ()

// 服务端
@property (nonatomic, strong) SocketCocoaAsynServer *socketServer;

@end

@implementation SocketServerCocoaAsyncController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 * 初始化socket
 */
- (void)initServerSocket
{
    __weak typeof(self) weakSelf = self;
    self.socketServer = [[SocketCocoaAsynServer alloc]init];
    // 收到客户端发送的消息回调
    self.socketServer.recMessageCallBack = ^(SocketClientModel * _Nonnull newClientModel, NSString * _Nonnull message) {
        // 把客户端的ip和port添加到消息的前面
        NSString *msg = [NSString stringWithFormat:@"%@:%ld说:%@",newClientModel.ipAddress,newClientModel.port,message];
        [weakSelf recMessage:msg];
    };
    
    // 有新的客户端连接回调
    self.socketServer.newClientConnectCallBack = ^(SocketClientModel * _Nonnull newClientModel, NSInteger connectedCount) {
        [weakSelf newClientConnect:[NSString stringWithFormat:@"%@:%ld",newClientModel.ipAddress,(long)newClientModel.port] clientCount:connectedCount];
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
    BOOL result = [self.socketServer startListenPort:port];
    [self startListenResultHandle:result];
}

/**
 * 停止监听(关闭服务器)
 */
- (void)stopListen
{
    __weak typeof(self) weakSelf = self;
    [self.socketServer stopListen:^(BOOL success) {
        [weakSelf stopListenResultHandle:success];
    }];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [self.socketServer sendBroadcastMessage:message];
}

@end
