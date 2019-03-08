//
//  SocketCoreClient.h
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketCoreFoundationClient : NSObject

// 是否已经连接服务端
@property (nonatomic, assign, readonly) BOOL isConnected;

// 接收到消息回调
@property (nonatomic, copy) void (^recMessageCallBack)(NSString *msg);

/**
 * 建立连接
 * ip 服务端的ip
 * port 服务端端口
 * complete 连接结果回调
 */
- (void)connectionToServer:(NSString *)ip port:(NSInteger)port complete:(void (^)(BOOL success))complete;

/**
 * 发送消息给服务端
 */
- (void)sendMessage:(NSString *)message result:(void (^)(BOOL success))result;

/**
 * 断开连接
 */
- (void)disConnect;

@end

NS_ASSUME_NONNULL_END