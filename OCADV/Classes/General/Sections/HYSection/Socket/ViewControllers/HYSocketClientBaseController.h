//
//  SocketClientController.h
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYSocketClientView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketClientBaseController : UIViewController
/**
 * 初始化socket
 */
- (void)initSocket;

/**
 * 连接服务端
 */
- (void)connectionToServer:(NSString *)serverIP port:(NSInteger)port;

/**
 * 断开与服务器的连接
 */
- (void)disconnect;

/**
 * 连接服务端结果处理
 */
- (void)connetResultHandle:(BOOL)result;

/**
 * 断开连接服务端结果处理
 */
- (void)disconnetResultHandle:(BOOL)result;

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message;

/**
 * 发送消息结果处理
 */
- (void)sendMessageResultHandle:(BOOL)result;

/**
 * 收到消息
 */
- (void)receiveMessage:(NSString *)message;

/**
 * 服务器断开连接
 */
- (void)serverDisconnectHandle;

/**
 * 显示loadingview
 */
- (void)showLoadingView:(NSString *)title;

/**
 * 隐藏loadingView
 */
- (void)hiddenLoadingView;

@end

NS_ASSUME_NONNULL_END
