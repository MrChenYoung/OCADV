//
//  SocketCocoaAsynServer.h
//  OCADV
//
//  Created by MrChen on 2018/12/7.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketCocoaAsynServer : NSObject

// 是否正在监听
@property (nonatomic, assign, readonly) BOOL isListening;

/**
 * 开启服务端,监听端口
 */
- (BOOL)startListenPort:(NSInteger)port;

/**
 * 停止监听(关闭服务端)
 */
- (void)stopListen:(void (^)(BOOL success))disconnectCallBack;

/**
 * 有新的客户端连接回调
 * userData 新连接的客户端携带的用户信息
 * connectedCount 当前连接的客户端数量
 */
@property (nonatomic, copy) void (^newClientConnectCallBack)(SocketClientModel *newClientModel,NSInteger connectedCount);

/**
 * 有客户端断开连接
 * userData 断开连接的客户端的携带的用户信息
 * connectedCount 当前连接的客户端数量
 */
@property (nonatomic, copy) void (^clientDisconnectionCallBack)(SocketClientModel *newClientModel,NSInteger connectedCount);

/**
 * 发送消息给所有连接的客户端
 */
- (void)sendBroadcastMessage:(NSString *)message;

// 服务端接收到客户端发送的消息回调
@property (nonatomic, copy) void (^recMessageCallBack)(SocketClientModel *newClientModel,NSString *message);

@end

NS_ASSUME_NONNULL_END
