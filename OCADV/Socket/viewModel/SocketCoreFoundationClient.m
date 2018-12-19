//
//  SocketCoreClient.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketCoreFoundationClient.h"

#import <arpa/inet.h>

@interface SocketCoreFoundationClient ()

@property (nonatomic, assign) BOOL isConnected;

// 客户端socket
@property (nonatomic, assign) CFSocketRef clientSocket;

// 连接服务端结果回调
@property (nonatomic, copy) void (^connectResult)(BOOL success);

@end

@implementation SocketCoreFoundationClient

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
    //    CFSocketContext socketContext = {
    //        0,
    //        (__bridge void *)self,
    //        &CFRetain,
    //        &CFRelease,
    //        NULL};
    CFSocketContext socketContext = {
        0,
        (__bridge void *)self,NULL,NULL,NULL};
    _clientSocket = CFSocketCreate(kCFAllocatorDefault,
                                   PF_INET,
                                   SOCK_STREAM,
                                   IPPROTO_TCP,
                                   kCFSocketConnectCallBack,
                                   TCPServerConnectCallBack,
                                   &socketContext);
    if (_clientSocket == nil) {
        NSLog(@"初始化socket失败");
    }
}

/**
 * 建立连接
 * ip 服务端的ip
 * port 服务端端口
 * complete 连接结果回调
 */
- (void)connectionToServer:(NSString *)ip port:(NSInteger)port complete:(void (^)(BOOL success))complete
{
    // 连接服务端结果回调函数设置
    self.connectResult = complete;
    
    // 子线程中连接服务端（尝试子线程中连接服务器，不调用TCPServerConnectCallBack回调函数，所以直接用主线程调用）
    NSArray *params = [NSArray arrayWithObjects:ip,[NSNumber numberWithInteger:port], nil];
//    [NSThread detachNewThreadSelector:@selector(connectToServer:) toTarget:self withObject:params];
    [self connectToServer:params];
}

- (void)connectToServer:(NSArray *)params
{
    NSString *ip = params.firstObject;
    NSInteger port = [params[1] integerValue];
    
    // 连接服务端
    struct sockaddr_in sAddr = {0};
    memset(&sAddr, 0, sizeof(sAddr));
    
    sAddr.sin_len = sizeof(sAddr);
    sAddr.sin_family = AF_INET;
    sAddr.sin_port = htons(port);
    sAddr.sin_addr.s_addr = inet_addr([ip UTF8String]);
    
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sAddr, sizeof(sAddr));
    CFSocketError result = CFSocketConnectToAddress(self.clientSocket, address, -1);
    
    CFRunLoopRef cRunRef = CFRunLoopGetCurrent();
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.clientSocket, 0);
    CFRunLoopAddSource(cRunRef, sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    
    BOOL success = result == kCFSocketSuccess;
    if (success) {
        NSLog(@"连接服务器成功");
    }else {
        NSLog(@"连接服务器失败");
        self.isConnected = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.connectResult) {
                self.connectResult(false);
            }
        });
    }
}


/**
 * 发送消息给服务端
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result
{
    // 发送消息
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const char *send_message = [message cStringUsingEncoding:NSUTF8StringEncoding];
        ssize_t sendCount = send(CFSocketGetNative(weakSelf.clientSocket), send_message, strlen(send_message) + 1, 0);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sendCount == -1) {
                // 发送失败
                if (result) {
                    result(NO);
                }
            }else {
                // 发送成功
                if (result) {
                    result(YES);
                }
            }
        });
    });
}

/**
 * 读取收到的消息
 */
- (void)readMessage
{
    // 消息缓冲
    char buffer[1024];
    __block NSString *message = nil;

    // 读取消息
    do {
        ssize_t recvLength = recv(CFSocketGetNative(_clientSocket), buffer, sizeof(buffer), 0);
        if (recvLength > 0) {
            message = [NSString stringWithFormat:@"%s",buffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recMessageCallBack) {
                    self.recMessageCallBack(message);
                }
            });
        }
    }while (strcmp(buffer, "exit") != 0);
}

/**
 * 断开连接
 */
- (void)disConnect
{
    CFSocketInvalidate(_clientSocket);
    CFRelease(_clientSocket);
}

/**
 * socket 回调函数，函数格式可在socket创建函数里查看
 */
void TCPServerConnectCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    SocketCoreFoundationClient *client = (__bridge SocketCoreFoundationClient *)info;
    if (data != NULL && type == kCFSocketConnectCallBack) {
        // 连接失败
        client.isConnected = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (client.connectResult) {
                client.connectResult(false);
            }
        });
    }else {
        // 连接成功
        client.isConnected = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (client.connectResult) {
                client.connectResult(YES);
            }
        });
        
        // 使用异步线程监听有没有收到数据
        [NSThread detachNewThreadSelector:@selector(readMessage) toTarget:client withObject:nil];
    }
}

@end
