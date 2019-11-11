//
//  SocketClientView.h
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYSocketClientView : UIView

// 客户端是否连接
@property (nonatomic, assign) BOOL isConnected;

// 消息输入框
@property (nonatomic, strong) UITextView *messageTextView;

// 服务端ip
@property (nonatomic, strong) UITextView *ipTextView;

// 服务端端口号
@property (nonatomic, strong) UITextView *portTextView;

// 连接服务端按钮点击回调
@property (nonatomic, copy) void (^connectBtnClick)(void);

// 发送消息按钮点击回调
@property (nonatomic, copy) void (^sendMsgBtnClick)(void);

// 点开与服务端的连接按钮点击回调
@property (nonatomic, copy) void (^disconnectBtnClick)(void);

// 接收到的消息
@property (nonatomic, strong) UITextView *recTextView;

// 发送消息按钮
@property (nonatomic, strong) HYButton *sendMsgBtn;


/**
 * 创建提示label
 */
+ (UILabel *)createTipLabel:(CGRect)frame text:(NSString *)text superView:(UIView *)superView;

/**
 * 创建输入框
 */
+ (UITextView *)createInputTextFiled:(CGRect)frame placeHold:(NSString *)placeHold superView:(UIView *)superView;

@end

NS_ASSUME_NONNULL_END
