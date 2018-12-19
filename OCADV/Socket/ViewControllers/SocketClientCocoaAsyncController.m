//
//  SocketClientCocoaAsyncController.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketClientCocoaAsyncController.h"
#import "SocketCocoaAsyncClient.h"

@interface SocketClientCocoaAsyncController ()

// 客户端socket2
@property (nonatomic, strong) SocketCocoaAsyncClient *socketCocoaAsyncClient;

@end

@implementation SocketClientCocoaAsyncController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**
 * 初始化socket
 */
- (void)initSocket
{
    __weak typeof(self) weakSelf = self;
    self.socketCocoaAsyncClient = [[SocketCocoaAsyncClient alloc]init];
    // 收到服务器发送的消息回调
    self.socketCocoaAsyncClient.recMessageCallBack = ^(NSString * _Nonnull msg) {
        [weakSelf receiveMessage:msg];
    };
    
    // 服务器断开连接回调
    self.socketCocoaAsyncClient.serverDisconnectCallBack = ^{
        [weakSelf serverDisconnectHandle];
    };
}

/**
 * 连接服务端
 */
- (void)connectionToServer:(NSString *)serverIP port:(NSInteger)port
{
    [super connectionToServer:serverIP port:port];
    
    __weak typeof(self) weakSelf = self;
    [self.socketCocoaAsyncClient connectionToServer:serverIP port:port complete:^(BOOL success) {
        [weakSelf connetResultHandle:success];
    }];
}

/**
 * 断开与服务器的连接
 */
- (void)disconnect
{
    [super disconnect];
    
    __weak typeof(self) weakSelf = self;
    [self.socketCocoaAsyncClient disconnect:^(BOOL success) {
        [weakSelf disconnetResultHandle:success];
    }];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    [super sendMessage:message];
    
    __weak typeof(self) weakSelf = self;
    [self.socketCocoaAsyncClient sendMessage:message result:^(BOOL success) {
        [weakSelf sendMessageResultHandle:success];
    }];
}


@end
