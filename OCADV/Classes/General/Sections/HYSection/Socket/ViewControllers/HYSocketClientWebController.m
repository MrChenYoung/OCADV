//
//  SocketClientWebController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketClientWebController.h"
#import "HYSocketWebSocketClient.h"

@interface HYSocketClientWebController ()

// socket
@property (nonatomic, strong) HYSocketWebSocketClient *socket;

@end

@implementation HYSocketClientWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"webSocket客户端";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self disconnect];
}

/**
 * 初始化socket
 */
- (void)initSocket
{
    __weak typeof(self) weakSelf = self;
    self.socket = [[HYSocketWebSocketClient alloc]init];

    // 收到服务器发送的消息回调
    self.socket.recMessageCallBack = ^(NSString * _Nonnull msg) {
        [weakSelf receiveMessage:msg];
    };

    // 服务器断开连接回调
    self.socket.serverDisconnectCallBack = ^{
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
    [self.socket connectionToHost:serverIP port:(int)port complete:^(BOOL success) {
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
    [self.socket disconnect:^(BOOL success) {
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
    [self.socket sendMessage:message result:^(BOOL success) {
        [weakSelf sendMessageResultHandle:success];
    }];
}

@end
