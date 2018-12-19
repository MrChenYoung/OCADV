//
//  SocketWebSocketClient.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketWebSocketClient.h"
#import <SRWebSocket.h>

@interface SocketWebSocketClient ()<SRWebSocketDelegate>

// socket
@property (nonatomic, strong) SRWebSocket *webSocket;

// 是否已经连接服务端
@property (nonatomic, assign) BOOL isConnected;

// 连接服务端结果回调
@property (nonatomic, copy) void (^connectResult)(BOOL success);

// 断开与服务端连接回调
@property (nonatomic, copy) void (^disconnectResult)(BOOL success);

@end

@implementation SocketWebSocketClient
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isConnected = NO;
    }
    return self;
}

/**
 * 连接服务端
 * host 服务端主机名
 * port 服务端端口号
 * complete 连接结果回调
 */
- (void)connectionToHost:(NSString *)host port:(int)port complete:(void (^)(BOOL success))complete
{
    if (!host) {
        NSLog(@"连接失败,服务器地址为空");
        return;
    }
    
    if (self.webSocket) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d",host,port]];
    self.webSocket = [[SRWebSocket alloc]initWithURL:url];
    self.webSocket.delegate = self;
    [self.webSocket setDelegateDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 连接服务端
    self.connectResult = complete;
    [self.webSocket open];
}

/**
 * 断开与服务器的连接
 */
- (void)disconnect:(void (^)(BOOL success))result
{
    self.disconnectResult = result;
    if (self.webSocket) {
        [self.webSocket close];
        self.webSocket = nil;
    }
}

/**
 * 发送消息给服务端
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result
{
    [self.webSocket send:message];
    
    if (result) {
        result(YES);
    }
}

#pragma mark - SRWebScokerDelegate
// 收到服务器消息
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recMessageCallBack) {
            self.recMessageCallBack(message);
        }
    });
}

// 连接成功
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    self.isConnected = YES;
    
    // 更新界面
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectResult) {
            self.connectResult(YES);
        }
    });
}

// 连接失败
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (error.code == 61) {
        // 服务器没有开启
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.connectResult) {
                self.connectResult(NO);
            }
        });
        
        // 关闭socket
        [self disconnect:nil];
    }
}

// 断开连接
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (wasClean) {
        // 客户端关闭
        self.isConnected = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.disconnectResult) {
                self.disconnectResult(YES);
            }
        });
    }else {
        // 服务器关闭
        [self disconnect:nil];
        self.isConnected = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.serverDisconnectCallBack) {
                self.serverDisconnectCallBack();
            }
        });
    }
}

//sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    NSLog(@"收到pong回调");
}

@end
