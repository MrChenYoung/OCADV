//
//  SocketCocoaAsynServer.m
//  OCADV
//
//  Created by MrChen on 2018/12/7.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketCocoaAsynServer.h"

@interface SocketCocoaAsynServer ()<GCDAsyncSocketDelegate>

// 是否正在监听
@property (nonatomic, assign) BOOL isListening;

// 已经连接的客户端socket模型
@property (nonatomic, strong) NSMutableArray<SocketClientModel *> *clientSocketModels;

// 服务器socket
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

// 服务端断开连接回调
@property (nonatomic, copy) void (^serverDisconnectCallBack)(BOOL success);

@end

@implementation SocketCocoaAsynServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 初始化客户端socket数组
        self.clientSocketModels = [NSMutableArray array];
        
        // 服务器socket
        _serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }
    return self;
}

/**
 * 开启服务端,监听端口
 */
- (BOOL)startListenPort:(NSInteger)port
{
    if (self.isListening) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"服务器已经开启,不能重复开启" inCtr:nil];
        return NO;
    }
    
    NSError *error = nil;
    BOOL result = [_serverSocket acceptOnPort:port error:&error];
    
    if (result || !error) {
        // 开启服务端成功
        self.isListening = YES;
        return YES;
    }else {
        // 开启服务端失败
        self.isListening = NO;
        return NO;
    }
}

/**
 * 停止监听(关闭服务端)
 */
- (void)stopListen:(void (^)(BOOL))disconnectCallBack
{
    self.serverDisconnectCallBack = disconnectCallBack;
    [_serverSocket disconnect];
}

/**
 * 发送消息给所有连接的客户端
 */
- (void)sendBroadcastMessage:(NSString *)message
{
    // 调用哪个客户端socket的writeData方法b，表示给哪个客户端发送消息
    [self.clientSocketModels enumerateObjectsUsingBlock:^(SocketClientModel *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GCDAsyncSocket *client = (GCDAsyncSocket *)obj.socket;
        [client writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }];
}


#pragma mark - GCDAsyncSocketDelegate
// 有客户端连接
// sock为服务端的socket，服务端的socket只负责客户端的连接，不负责数据的读取。   newSocket为客户端的socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // 获取连接客户端的ip和端口
    NSString *ip = newSocket.connectedHost;
    int port = newSocket.connectedPort;
    
    // 保存客户端的socket，如果不保存，服务器会自动断开与客户端的连接（客户端那边会报断开连接的log)
    SocketClientModel *model = [[SocketClientModel alloc]init];
    model.socket = newSocket;
    model.ipAddress = ip;
    model.port = port;
    [self.clientSocketModels addObject:model];
    
    // 更新界面
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.newClientConnectCallBack) {
            self.newClientConnectCallBack(model,self.clientSocketModels.count);
        }
    });
    
    // 读取数据
    [newSocket readDataWithTimeout:-1 tag:0];
}

/**
 * 客户端断开连接回调
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock == self.serverSocket) {
        // 服务端断开连接
        self.isListening = err != nil;
        
        // 断开已经连接的客户端
        for (SocketClientModel *model in self.clientSocketModels) {
            GCDAsyncSocket *clientSocket = model.socket;
            [clientSocket disconnect];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.serverDisconnectCallBack) {
                self.serverDisconnectCallBack(err == nil);
            }
        });
    
        return;
    }
    
    // 删除断开连接的客户端
    NSMutableArray *removeClient = [NSMutableArray array];
    for (SocketClientModel *client in self.clientSocketModels) {
        if (client.socket == sock) {
            [removeClient addObject:client];
        }
    }
    for (SocketClientModel *model in removeClient) {
        [self.clientSocketModels removeObject:model];
    }
    
    // 更新界面
    dispatch_async(dispatch_get_main_queue(), ^{
        for (SocketClientModel *disconnectClient in removeClient) {
            if (self.clientDisconnectionCallBack) {
                self.clientDisconnectionCallBack(disconnectClient, self.clientSocketModels.count);
            }
        }
    });
}

// 服务端写数据给客户端
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [sock readDataWithTimeout:-1 tag:0];
}

/**
 * 服务端读取到客户端发送的数据
 * sock 客户端socket
 * data 客户端发送的消息
 * tag 当前读取的标记
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receiverStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    // 把回车和换行字符去掉，接收到的字符串有时候包括这2个，导致判断quit指令的时候判断不相等
    receiverStr = [receiverStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    receiverStr = [receiverStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.recMessageCallBack) {
            SocketClientModel *clientModel = [[SocketClientModel alloc]init];
            clientModel.socket = sock;
            clientModel.ipAddress = sock.connectedHost;
            clientModel.port = sock.connectedPort;
            self.recMessageCallBack(clientModel,receiverStr);
        }
    });

    
    // 保证下一条消息也能收到（如果不添加这一行代码，只能收到第一条消息）
    [sock readDataWithTimeout:-1 tag:0];
    
    //判断是登录指令还是发送聊天数据的指令。这些指令都是自定义的
    //登录指令
//    if([receiverStr hasPrefix:@"iam:"]){
//        // 获取用户名
//        NSString *user = [receiverStr componentsSeparatedByString:@":"][1];
//        // 响应给客户端的数据
//        NSString *respStr = [user stringByAppendingString:@"has joined"];
//        [sock writeData:[respStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    }
//
//    //聊天指令
//    if ([receiverStr hasPrefix:@"msg:"]) {
//        //截取聊天消息
//        NSString *msg = [receiverStr componentsSeparatedByString:@":"][1];
//        [sock writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    }
//
//    //quit指令
//    if ([receiverStr isEqualToString:@"quit"]) {
//        //断开连接
//        [sock disconnect];
//        //移除socket
//        [self.clientSockets removeObject:sock];
//    }
}

@end
