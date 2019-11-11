//
//  SocketClientModel.h
//  OCADV
//
//  Created by MrChen on 2018/12/11.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketClientModel : NSObject

/**
 * 客户端对应的socket
 * 如果用CocoaAsyn框架 socket为GCDAsyncSocket类型
 * 
 */
@property (nonatomic, strong) id socket;

// 客户端地址
@property (nonatomic, copy) NSString *ipAddress;

// 客户端端口号
@property (nonatomic, assign) NSInteger port;

@end

NS_ASSUME_NONNULL_END
