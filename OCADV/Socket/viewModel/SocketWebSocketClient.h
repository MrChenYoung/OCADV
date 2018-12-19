//
//  SocketWebSocketClient.h
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketWebSocketClient : NSObject

// 是否已经连接服务端
@property (nonatomic, assign, readonly) BOOL isConnected;

// 服务器断开连接
@property (nonatomic, copy) void (^serverDisconnectCallBack)(void);

// 接收到消息回调
@property (nonatomic, copy) void (^recMessageCallBack)(NSString *msg);

/**
 * 连接服务端
 * host 服务端主机名
 * port 服务端端口号
 * complete 连接结果回调
 */
- (void)connectionToHost:(NSString *)host port:(int)port complete:(void (^)(BOOL success))complete;

/**
 * 断开与服务器的连接
 */
- (void)disconnect:(nullable void (^)(BOOL success))result;

/**
 * 发送消息给服务端
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result;

@end

NS_ASSUME_NONNULL_END
