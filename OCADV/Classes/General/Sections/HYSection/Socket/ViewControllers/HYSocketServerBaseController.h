//
//  SocketServerController.h
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketServerBaseController : UIViewController

// 开启监听回调
@property (nonatomic, copy) void (^startListen)(BOOL success);

/**
 * 初始化socket
 */
- (void)initServerSocket;

/**
 * 开启监听指定端口
 */
- (void)startListen:(NSInteger)port;

/**
 * 停止监听(关闭服务器)
 */
- (void)stopListen;

/**
 * 收到消息
 */
- (void)recMessage:(NSString *)message;

/**
 * 有新的客户端连接
 */
- (void)newClientConnect:(id)userData clientCount:(NSInteger)clientCount;

/**
 * 客户端断开连接
 */
- (void)clientDisconnect:(id)userData clientCount:(NSInteger)clientCount;

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message;

/**
 * 开启监听结果处理
 */
- (void)startListenResultHandle:(BOOL)success;

/**
 * 关闭监听结果处理
 */
- (void)stopListenResultHandle:(BOOL)success;

@end

NS_ASSUME_NONNULL_END
