//
//  SocketCoreFoundationServer.m
//  OCADV
//
//  Created by MrChen on 2018/12/9.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketCoreFoundationServer.h"
#import <arpa/inet.h>

@interface HYSocketCoreFoundationServer ()

// socket
@property (nonatomic, assign) CFSocketRef socketServer;

// 连接的客户端
@property (nonatomic, strong) NSMutableArray<HYSocketClientModel *> *connectedClients;

@property (nonatomic, strong) HYSocketClientModel *currentClientModel;

@end

@implementation HYSocketCoreFoundationServer

CFReadStreamRef readStreamRef;

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
    self.connectedClients = [NSMutableArray array];
    
    CFSocketContext socketContext = {
        0,
        (__bridge void *)self,NULL,NULL,NULL};
    
    /**
     * 创建Socket， 指定TCPServerAcceptCallBack
     * 作为kCFSocketAcceptCallBack 事件的监听函数
     * 参数1： 指定协议族，如果参数为0或者负数，则默认为PF_INET
     * 参数2：指定Socket类型，如果协议族为PF_INET，且该参数为0或者负数，则它会默认为SOCK_STREAM,如果要使用UDP协议，则该参数指定为SOCK_DGRAM
     * 参数3：指定通讯协议。如果前一个参数为SOCK_STREAM,则默认为使用TCP协议，如果前一个参数为SOCK_DGRAM,则默认使用UDP协议
     * 参数4：指定下一个函数所监听的事件类型
     */
    _socketServer = CFSocketCreate(kCFAllocatorDefault,
                                   PF_INET,
                                   SOCK_STREAM,
                                   IPPROTO_TCP,
                                   kCFSocketAcceptCallBack,
                                   TCPServerAcceptCallBack,
                                   &socketContext);
    
    if (_socketServer == NULL) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"初始化socket失败" inCtr:nil];
        return;
    }
    
    // 设置允许重用本地地址和端口
    BOOL reused = YES;
    setsockopt(CFSocketGetNative(_socketServer), SOL_SOCKET, SO_REUSEADDR, (const void *)&reused,sizeof(reused));
}

/**
 * 开启服务端,监听端口
 */
- (void)startListenPort:(NSInteger)port result:(void (^)(BOOL success))result
{
    if (_socketServer == NULL) {
        [self initSocket];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 定义sockaddr_in类型的变量， 该变量将作为CFSocket的地址
        struct sockaddr_in socketAddr;
        memset(&socketAddr, 0, sizeof(socketAddr));
        socketAddr.sin_len = sizeof(socketAddr);
        socketAddr.sin_family = AF_INET;

        //设置服务器监听地址(默认本机ip地址)
        //    socketAddr.sin_addr.s_addr = inet_addr("");

        //设置服务器监听端口
        socketAddr.sin_port = htons(port);

        //将ipv4 的地址转换为CFDataRef
        CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&socketAddr, sizeof(socketAddr));

        //将CFSocket 绑定到指定IP地址
        if (CFSocketSetAddress(weakSelf.socketServer, address) != kCFSocketSuccess) {
            //如果_socket 不为NULL， 则释放_socket
            if (weakSelf.socketServer) {
                CFRelease(weakSelf.socketServer);
            }

            weakSelf.socketServer = NULL;

            // 开启监听失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    result(NO);
                }
            });
            
            return ;
        }

        // 监听成功
        if (result) {
            result(YES);
        }

        //启动循环监听客户链接
        //获取当前线程的CFRunloop
        CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
        //将_socket包装成CFRunLoopSource
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, weakSelf.socketServer, 0);
        //为CFRunLoop对象添加source
        CFRunLoopAddSource(runloopRef, source, kCFRunLoopCommonModes);
        CFRelease(source);
        // 启动runloop
        CFRunLoopRun();
    });
}

/**
 * 停止监听
 */
- (void)stopListen
{
    if (_socketServer) {
        CFSocketInvalidate(_socketServer);
        CFRelease(_socketServer);
        _socketServer = NULL;
    }
}

/**
 * 发送消息给所有连接的客户端
 */
- (void)sendBroadcastMessage:(NSString *)message
{
    const char *msg = message.UTF8String;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < self.connectedClients.count; i++) {
            CFWriteStreamRef writeRef = (__bridge CFWriteStreamRef)(self.connectedClients[i]);
            CFWriteStreamWrite(writeRef, (UInt8 *)msg, strlen(msg) + 1);
        }
    });
}

/**
 * 读取客户端发送来的数据
 */
void readStream(CFReadStreamRef readStream, CFStreamEventType eventype, void * clientCallBackInfo)
{
    char buff[2048];
    HYSocketCoreFoundationServer *server = (__bridge HYSocketCoreFoundationServer *)clientCallBackInfo;
    CFIndex hasRead = CFReadStreamRead(readStream, (UInt8 *)buff, sizeof(buff));

    if (hasRead > 0) {
        NSString *str = [NSString stringWithFormat:@"%s",buff];
        str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"服务端收到消息:%@",str);
        
        // 去掉回车和换行
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (server.recMessageCallBack) {
                server.recMessageCallBack(str);
            }
        });
    }else if (hasRead == 0){
        // 客户端断开连接
        dispatch_async(dispatch_get_main_queue(), ^{
            if (server.clientDisconnectionCallBack) {
                server.clientDisconnectionCallBack(server.currentClientModel, server.connectedClients.count);
            }
        });
    }else if (hasRead == -1){
        // 服务端关闭
        
    }
}

/**
 * 回调
 */
void TCPServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info)
{
    //如果有客户端Socket连接进来
    if (kCFSocketAcceptCallBack == type) {
        HYSocketCoreFoundationServer *sockServer = (__bridge HYSocketCoreFoundationServer *)info;

        //获取本地Socket的Handle， 这个回调事件的类型是kCFSocketAcceptCallBack，这个data就是一个CFSocketNativeHandle类型指针
        CFSocketNativeHandle nativeHandle = *(CFSocketNativeHandle *)data;

        //定义一个255数组接收这个新的data转成的socket的地址，SOCK_MAXADDRLEN表示最长的可能的地址
        uint8_t name[SOCK_MAXADDRLEN];
        socklen_t namelen = sizeof(name);

        /**
         * 获取连接socket的信息
         */
        if (getpeername(nativeHandle, (struct sockaddr *)name, &namelen) != 0) {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"获取连接客户端信息失败" inCtr:nil];
            return;
        }

        // 获取连接客户端的ip和端口
        struct sockaddr_in *add_in = (struct sockaddr_in *)name;
        char *ip = inet_ntoa(add_in->sin_addr);
        NSInteger port = ntohs(add_in->sin_port);

        //创建一组可读/可写的CFStream
        readStreamRef = NULL;
        CFWriteStreamRef writeStreamRef = NULL;

        //创建一个和Socket对象相关联的读取数据流
        //参数1 ：内存分配器
        //参数2 ：准备使用输入输出流的socket
        //参数3 ：输入流
        //参数4 ：输出流
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, //内存分配器
                                     nativeHandle,        //准备使用输入输出流的socket
                                     &readStreamRef,      //输入流
                                     &writeStreamRef);    //输出流

        //CFStreamCreatePairWithSocket() 操作成功后，readStreamRef和writeStream都指向有效的地址，因此判断是不是还是之前设置的NULL就可以了
        if (readStreamRef && writeStreamRef) {
            // 记录连接的客户端
            HYSocketClientModel *clientModel = [[HYSocketClientModel alloc]init];
            clientModel.ipAddress = [NSString stringWithFormat:@"%s",ip];
            clientModel.port = port;
            clientModel.socket = (__bridge id _Nonnull)(writeStreamRef);
            [sockServer.connectedClients addObject:clientModel];
            sockServer.currentClientModel = clientModel;
            
            //打开输入流 和输出流
            CFReadStreamOpen(readStreamRef);
            CFWriteStreamOpen(writeStreamRef);

            //一个结构体包含程序定义数据和回调用来配置客户端数据流行为
            CFStreamClientContext context = {0, info, NULL, NULL };

            //指定客户端的数据流， 当特定事件发生的时候， 接受回调
            //参数1 : 需要指定的数据流
            //参数2 : 具体的事件，如果为NULL，当前客户端数据流就会被移除
            //参数3 : 事件发生回调函数，如果为NULL，同上
            //参数4 : 一个为客户端数据流保存上下文信息的结构体，为NULL同上
            //CFReadStreamSetClient  返回值为true 就是数据流支持异步通知， false就是不支持
            if (!CFReadStreamSetClient(readStreamRef, kCFStreamEventHasBytesAvailable, readStream, &context)) {
                // 新客户端连接失败
                [HYAlertUtil showAlertTitle:@"提示" msg:@"新客户端连接失败" inCtr:nil];
                return;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                if (sockServer.newClientConnectCallBack) {
                    sockServer.newClientConnectCallBack(clientModel, sockServer.connectedClients.count);
                }
            });

            //将数据流加入循环
            CFReadStreamScheduleWithRunLoop(readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        }else{
            //如果失败就销毁已经连接的socket
            close(nativeHandle);
        }
    }
}

@end
