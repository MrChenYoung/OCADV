//
//  SocketFoundationServer.m
//  OCADV
//
//  Created by MrChen on 2018/12/10.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketFoundationServer.h"
#import <arpa/inet.h>

@interface HYSocketFoundationServer ()

// 服务器socket
@property (nonatomic, assign) int serverSocket;

// 已经连接的客户端
@property (nonatomic, strong) NSMutableArray<HYSocketClientModel *> *connectedClients;

// 正在监听flag
@property (nonatomic, assign) BOOL isListening;

@end

@implementation HYSocketFoundationServer

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
    // 所有已经连接的客户端
    self.connectedClients = [NSMutableArray array];
    self.isListening = NO;
    
    _serverSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    
    if (_serverSocket == -1) {
        // 初始化socket失败
        [HYAlertUtil showAlertTitle:@"提示" msg:@"初始化socket失败" inCtr:nil];
    }
}

/**
 * 开启服务端,监听端口
 */
- (void)startListenPort:(NSInteger)port result:(void (^)(BOOL success))result
{
    if (self.isListening) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"服务器已经开启,不能重复开启" inCtr:nil];
        return;
    }
    
    struct sockaddr_in addr;
    // 清零
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = INADDR_ANY;
    
    // 绑定端口号
    int errorCode = bind(_serverSocket, (const struct sockaddr *)&addr, sizeof(addr));
    if (errorCode == 0) {
        // 绑定成功,开始监听 2位等待连接数目
        int listenResult = listen(_serverSocket, 1);
        if (listenResult == 0) {
            // 监听成功
            if (result) {
                result(YES);
            }
            
            // 监听客户端的连接
            self.isListening = YES;
            [self acceptClient];
        }else {
            // 监听失败
            if (result) {
                result(NO);
            }
        }
    }else {
        // 绑定失败
        if (result) {
            result(NO);
        }
    }
}

/**
 * 监听客户端的连接
 */
- (void)acceptClient
{
    // 持续监听客户端的连接
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (weakSelf.isListening) {
            struct sockaddr_in peeraddr;
            socklen_t addrLen;
            addrLen = sizeof(peeraddr);
            
            // 接受到客户端clientSocket连接,获取到地址和端口(阻塞知道有客户端连接进来)
            int clientSocket = accept(weakSelf.serverSocket, (struct sockaddr *)&peeraddr, &addrLen);
            if (clientSocket != -1) {
                // 连接成功,记录并保存连接客户端的信息
                NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(peeraddr.sin_addr)];
                NSInteger port = ntohs(peeraddr.sin_port);
                NSNumber *client = [NSNumber numberWithInt:clientSocket];
                HYSocketClientModel *clientModel = [[HYSocketClientModel alloc]init];
                clientModel.ipAddress = ip;
                clientModel.port = port;
                clientModel.socket = client;
                [weakSelf.connectedClients addObject:clientModel];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.newClientConnectCallBack) {
                        weakSelf.newClientConnectCallBack(clientModel, weakSelf.connectedClients.count);
                    }
                });
                
                // 接收客户端发送的消息
                [weakSelf receiveMessage:clientSocket];
            }else {
                // 服务器断开连接
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.serverStopCallBack) {
                        weakSelf.serverStopCallBack();
                    }
                });
            }
        }
    });
}

/**
 * 停止监听
 */
- (void)stopListen
{
    self.isListening = NO;
    
    // 断开服务端socket
    shutdown(_serverSocket, SHUT_RDWR);
    close(_serverSocket);
    
    // 断开客户端socket
    for (HYSocketClientModel *clientSocket in self.connectedClients) {
        int client = [clientSocket.socket intValue];
        shutdown(client, SHUT_RDWR);
        close(client);
    }
    [self.connectedClients removeAllObjects];
}

/**
 * 接收到客户端发送的消息
 */
- (void)receiveMessage:(int)clientSocket
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char buff[1024];
        size_t len = sizeof(buff);
        
        // 循环监听消息的到来
        ssize_t recLength;
        do {
            recLength = recv(clientSocket, buff, len, 0);
            NSLog(@"服务端收到消息长度:%zd,%d",recLength,strcmp(buff, "exit"));
            
            if (recLength > 0) {
                NSData *data = [[NSData alloc]initWithBytes:buff length:recLength];
                NSString *recMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                // 获取客户端socket的ip和端口
                HYSocketClientModel *currentClentModel = nil;
                for (HYSocketClientModel *clientModel in weakSelf.connectedClients) {
                    NSNumber *clientSocketId = clientModel.socket;
                    if (clientSocketId.intValue == clientSocket) {
                        currentClentModel = clientModel;
                        break;
                    }
                }
                
                // 更新界面
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.recMessageCallBack) {
                        weakSelf.recMessageCallBack(currentClentModel,recMessage);
                    }
                });
            }else {
                // 客户端断开连接
                // 记录断开的客户端
                NSMutableArray *removeClients = [NSMutableArray array];
                for (HYSocketClientModel *model in weakSelf.connectedClients) {
                    if ([model.socket intValue] == clientSocket) {
                        [removeClients addObject:model];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (HYSocketClientModel *client in removeClients) {
                        // 移除客户端
                        [weakSelf.connectedClients removeObject:client];
                        
                        // 更新界面
                        if (weakSelf.clientDisconnectionCallBack) {
                            weakSelf.clientDisconnectionCallBack(client, weakSelf.connectedClients.count);
                        }
                    }
                });
            }
        } while (strcmp(buff, "exit") != 0 && recLength != 0 && weakSelf.isListening);
    });
}

/**
 * 发送消息给所有连接的客户端
 */
- (void)sendBroadcastMessage:(NSString *)message
{
    const char *msg = message.UTF8String;
    
    for (HYSocketClientModel *client in self.connectedClients) {
        int clientSocket = [client.socket intValue];
        ssize_t sendLen = send(clientSocket, msg, strlen(msg), 0);
        if (sendLen > 0) {
            NSLog(@"发送成功");
        }else {
            NSLog(@"发送消失失败");
        }
    }
}



@end
