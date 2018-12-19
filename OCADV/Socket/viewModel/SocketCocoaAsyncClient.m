//
//  SocketCocoaAsyncClient.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketCocoaAsyncClient.h"

@interface SocketCocoaAsyncClient ()<GCDAsyncSocketDelegate>
// 是否已经连接服务端
@property (nonatomic, assign) BOOL isConnected;

// socket
@property (nonatomic, strong) GCDAsyncSocket *socket;

// 连接服务端结果回调
@property (nonatomic, copy) void (^connectResult)(BOOL success);

// 断开与服务端连接回调
@property (nonatomic, copy) void (^disconnectResult)(BOOL success);

// 发送消息结果回调
@property (nonatomic, copy) void (^sendMsgResult)(BOOL success);

@end

@implementation SocketCocoaAsyncClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化socket
        [self initSocket];
    }
    return self;
}

/**
 * 初始化socket
 */
- (void)initSocket
{
    // 创建socket对象
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }

    self.isConnected = NO;
}

/**
 * 建立连接
 * ip 服务端的ip
 * port 服务端端口
 * complete 连接结果回调
 */
- (void)connectionToServer:(NSString *)ip port:(NSInteger)port complete:(void (^)(BOOL success))complete
{
    [self initSocket];
    
    self.connectResult = complete;
    
    NSError *error = nil;
    BOOL result = [_socket connectToHost:ip onPort:port error:&error];
    if (result || !error) {
        // 连接成功
//        if (complete) {
//            complete(YES);
//        }
    }else {
        // 连接失败
        self.isConnected = NO;
        if (complete) {
            complete(NO);
        }
    }
}

/**
 * 断开与服务器的连接
 */
- (void)disconnect:(void (^)(BOOL success))result
{
    self.disconnectResult = result;
    [self.socket disconnect];
}

/**
 * 发送消息给服务端
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result
{
    self.sendMsgResult = result;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.socket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    });
}

#pragma mark - GCDAsyncSocketDelegate
// 连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    self.isConnected = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectResult) {
            self.connectResult(YES);
        }
    });

    // 可以读取服务端的数据
    [sock readDataWithTimeout:-1 tag:0];
}

// 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        if (!_isConnected) {
            // 连接服务器失败 服务器未开启
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.connectResult) {
                    self.connectResult(NO);
                }
            });
        }else {
            // 断开服务器失败
            if (err.code == 7) {
                // 服务器断开连接
                [self disconnect:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.serverDisconnectCallBack) {
                        self.serverDisconnectCallBack();
                    }
                });
            }else {
                // 断开连接失败
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.disconnectResult) {
                        self.disconnectResult(NO);
                    }
                });
            }
        }
    }else {
        self.socket.delegate = nil;
        self.socket = nil;
        self.isConnected = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.disconnectResult) {
                self.disconnectResult(YES);
            }
        });
    }
}

// 发送数据成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.sendMsgResult) {
            weakSelf.sendMsgResult(YES);
        }
    });
    
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
}

// 读取数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recMessageCallBack) {
            self.recMessageCallBack(receiverStr);
        }
    });
    
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
