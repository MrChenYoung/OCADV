//
//  SocketFoundationClient.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketFoundationClient.h"
#import <arpa/inet.h>
//#import <unistd.h>
//#import <netinet/tcp.h>
//#import <sys/socket.h>
//#import <netinet/in.h>

@interface SocketFoundationClient ()

// socket
@property (nonatomic, assign) int clientSocket;

// 连接服务端结果回调
@property (nonatomic, copy) void (^connectResult)(BOOL success);

@end

@implementation SocketFoundationClient

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
    /** 创建socket
     * domain 协议域:常用AF_INET指定IPv4,AF_INET6基于ipv6
     * type socket类型：SOCK_STREAM流式(TCP传输),SOCK_DGRAM数据报(UDP传输)
     * protocol 基于的协议类型:IPPROTO_TCP TCP方式,IPPROTO_UDP UDP方式。可以设置为0，根据第二参数来自动确定协议类型
     * 返回值，如果创建成功返回的是socket的描述符(描述句柄)，失败返回-1
     * int socket(int domain, int type, int protocol);
     */
    _clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    if (_clientSocket == -1) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"初始化socket失败" inCtr:nil];
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
    self.connectResult = complete;

    // 子线程中连接服务器
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        struct sockaddr_in addr;
        // 设置ipv4地址
        addr.sin_family = AF_INET;
        // 指定ip地址
        addr.sin_addr.s_addr = inet_addr([ip cStringUsingEncoding:NSUTF8StringEncoding]);
        // 指定端口
        addr.sin_port = htons(port);
        /** 连接服务器
         *  sockfd 套接字描述符
         *  serv_addr 指向数据结构sockaddr的指针，其中包括目的端口和IP地址
         *  addrlen 参数二serv_addr的长度，可以通过sizeof(struct sockaddr)获取
         *  成功返回0 失败返回非0
         * int connect(int sockfd, struct sockaddr *serv_addr, int addrlen);
         */
        int result = connect(weakSelf.clientSocket, (const struct sockaddr *)&addr, sizeof(addr));
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result == 0) {
                // 连接成功
                if (self.connectResult) {
                    self.connectResult(YES);
                }
                
                // 异步监听收到的消息
                [NSThread detachNewThreadSelector:@selector(readMessage) toTarget:self withObject:nil];
            }else {
                // 连接失败
                if (self.connectResult) {
                    self.connectResult(NO);
                }
            }
        });
    });
}

/**
 * 监听收到消息
 */
- (void)readMessage
{
    NSString *message = nil;
    char buffer[1024];
    
    do {
        // recv函数会阻塞当前线程，监听服务端发送的消息，当有消息到来时把消息内容填入buffer中,相当于准备接收消息
        // 每次接收玩消息倒要再次调用这个函数，否则收不到后续消息
        ssize_t recCount = recv(_clientSocket, buffer, sizeof(buffer), 0);
        if (recCount > 0) {
            NSData *data = [NSData dataWithBytes:buffer length:recCount];
            message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            // 调用接收消息回调 展示消息到界面
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.recMessageCallBack) {
                    self.recMessageCallBack(message);
                }
            });
        }
    } while (strcmp(buffer, "exit") != 0);

}


/**
 * 发送消息给服务端
 * s 套接字id
 * msg 发送的消息
 * len 发送的消息的大小,不是字节数，而是字符数
 * flags 阻塞或者不阻塞，一般填0
 * 返回值，成功返回发送出去的字节数，失败返回-1
 * ssize_t   send(int s, const void *msg, size_t len, int flags) __DARWIN_ALIAS_C(send);
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result
{
    const char *msg = [message UTF8String];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ssize_t sendCount = send(weakSelf.clientSocket, msg, strlen(msg), 0);
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
 * 断开连接
 */
- (void)disConnect
{
    shutdown(_clientSocket, SHUT_RDWR);
    close(_clientSocket);
}

@end
