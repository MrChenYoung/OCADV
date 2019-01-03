//
//  SocketServerView.h
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketServerView : UIView

// 是否正在监听
@property (nonatomic, assign) BOOL isListening;

// 端口号输入框
@property (nonatomic, strong) UITextView *portTextView;

// 发送消息给客户端
@property (nonatomic, strong) UITextView *sendMessageTextView;

// 接收到客户端发送来的消息
@property (nonatomic, strong) UITextView *recMessageTextView;

// 连接的客户端列表
@property (nonatomic, strong) UITextView *onlineClientsTextView;

// 连接的客户端
@property (nonatomic, strong) UILabel *onlineClientsLabel;

// 开始监听回调
@property (nonatomic, copy) void (^startListenCallBack)(void);

// 停止监听回调
@property (nonatomic, copy) void (^stopListenCallBack)(void);

// 发送消息
@property (nonatomic, copy) void (^sendMessageCallBack)(void);



@end

NS_ASSUME_NONNULL_END
