//
//  SocketServerFApiController.m
//  OCADV
//
//  Created by MrChen on 2018/12/10.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketServerFApiController.h"
#import "SocketFoundationServer.h"

@interface SocketServerFApiController ()

// 服务端socket
@property (nonatomic, strong) SocketFoundationServer *serverSocket;

@end

@implementation SocketServerFApiController

- (void)viewDidLoad {
    [super viewDidLoad];

}

/**
 * 初始化socket
 */
- (void)initServerSocket
{
    self.serverSocket = [[SocketFoundationServer alloc]init];
    
    __weak typeof(self) weakSelf = self;
    // 有新的客户端连接
    self.serverSocket.newClientConnectCallBack = ^(SocketClientModel *newClientModel, NSInteger connectedCount) {
        [weakSelf newClientConnect:[NSString stringWithFormat:@"%@:%ld",newClientModel.ipAddress,newClientModel.port] clientCount:connectedCount];
    };
    
    // 有客户端断开连接
    self.serverSocket.clientDisconnectionCallBack = ^(SocketClientModel * _Nonnull newClientModel, NSInteger connectedCount) {
        [weakSelf clientDisconnect:[NSString stringWithFormat:@"%@:%ld",newClientModel.ipAddress,newClientModel.port] clientCount:connectedCount];
    };
    
    // 服务端断开连接
    self.serverSocket.serverStopCallBack = ^{
        [weakSelf stopListenResultHandle:YES];
    };
    
    // 收到客户端发送的消息
    self.serverSocket.recMessageCallBack = ^(SocketClientModel * _Nonnull clientModel, NSString * _Nonnull message) {
        NSString *msg = [NSString stringWithFormat:@"%@:%ld说:%@",clientModel.ipAddress,clientModel.port,message];
        [weakSelf recMessage:msg];
    };
}

/**
 * 开启监听指定端口
 */
- (void)startListen:(NSInteger)port
{
    // 开始监听
    __weak typeof(self) weakSelf = self;
    [self.serverSocket startListenPort:port result:^(BOOL success) {
        [weakSelf startListenResultHandle:success];
    }];
}

/**
 * 停止监听(关闭服务器)
 */
- (void)stopListen
{
    [self.serverSocket stopListen];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [self.serverSocket sendBroadcastMessage:message];
}

@end
