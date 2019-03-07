//
//  SocketClientView.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketClientView.h"

@interface HYSocketClientView()<UITextViewDelegate>

// 断开与服务器的连接按钮
@property (nonatomic, strong) HYButton *disconnectBtn;

@end

@implementation HYSocketClientView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScWidth, ScHeight);
        
        // 创建子视图
        [self createSubViews];
    }
    return self;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    CGRect ipPortFrame = CGRectMake(10, KNavigationBarH + 5, ScWidth - 20, 30);
    [HYSocketClientView createTipLabel:ipPortFrame text:@"连接到的ip和端口:" superView:self];
    
    // 服务端ip
    CGFloat totalW = ScWidth - 30;
    CGFloat height = 30;
    CGRect ipFrame = CGRectMake(10, CGRectGetMaxY(ipPortFrame) + 5, totalW * 0.8, height);
    _ipTextView = [HYSocketClientView createInputTextFiled:ipFrame placeHold:@"服务端ip" superView:self];
    _ipTextView.text = [IPUtil getIPAddress];
    
    // 服务端 端口
    CGRect portFrame = CGRectMake(CGRectGetMaxX(ipFrame) + 10, CGRectGetMinY(_ipTextView.frame), totalW * 0.2, height);
    _portTextView = [HYSocketClientView createInputTextFiled:portFrame placeHold:@"端口" superView:self];
    _portTextView.text = [NSString stringWithFormat:@"%d",SERVERPORT];
    
    // 接受到的消息
    CGRect recMsgTipFrame = CGRectMake(10, CGRectGetMaxY(portFrame) + 10, ScWidth - 20, 30);
    UILabel *recMsgTipLabel = [HYSocketClientView createTipLabel:recMsgTipFrame text:@"接收到的消息:" superView:self];
    CGRect recTextFrame = CGRectMake(10, CGRectGetMaxY(recMsgTipLabel.frame) + 5, ScWidth - 20, ScHeight * 0.2);
    _recTextView = [HYSocketClientView createInputTextFiled:recTextFrame placeHold:@"暂无接收到任何消息" superView:self];
    _recTextView.editable = NO;
    
    // 发送消息
    CGRect sendMsgTipFrame = CGRectMake(10, CGRectGetMaxY(recTextFrame) + 10, ScWidth - 20, 30);
    UILabel *sendMsgTipLabel = [HYSocketClientView createTipLabel:sendMsgTipFrame text:@"发送消息:" superView:self];
    CGRect messageFrame = CGRectMake(10, CGRectGetMaxY(sendMsgTipLabel.frame) + 5, ScWidth - 20, ScHeight * 0.2);
    _messageTextView = [HYSocketClientView createInputTextFiled:messageFrame placeHold:@"输入要发送的消息" superView:self];
    _messageTextView.returnKeyType = UIReturnKeySend;
    _messageTextView.delegate = self;
    _messageTextView.text = @"客户端消息";
    
    // 发送按钮
    _sendMsgBtn = [[HYButton alloc]init];
    _sendMsgBtn.btnY = CGRectGetMaxY(messageFrame) + 10;
    _sendMsgBtn.titleText = @"连接服务端";
    [_sendMsgBtn addTarget:self action:@selector(sendMsg) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sendMsgBtn];
    
    // 断开与服务器的连接按钮
    _disconnectBtn = [[HYButton alloc]init];
    _disconnectBtn.btnY = CGRectGetMaxY(_sendMsgBtn.frame) + 10;
    _disconnectBtn.titleText = @"断开与服务器的连接";
    [_disconnectBtn addTarget:self action:@selector(disconnect) forControlEvents:UIControlEventTouchUpInside];
    _disconnectBtn.clickAble = NO;
    [self addSubview:_disconnectBtn];
}

/**
 * 创建输入框
 */
+ (UITextView *)createInputTextFiled:(CGRect)frame placeHold:(NSString *)placeHold superView:(UIView *)superView
{
    UITextView *textView = [[UITextView alloc]initWithFrame:frame];
    textView.layer.borderColor = ColorLightGray.CGColor;
    textView.layer.borderWidth = 1;
    textView.layer.cornerRadius = textView.bounds.size.height * 0.1 > 5 ? 5 : textView.bounds.size.height * 0.1;
    textView.zw_placeHolder = placeHold;
    textView.font = [UIFont systemFontOfSize:14];
    [superView addSubview:textView];
    return textView;
}

/**
 * 创建提示label
 */
+ (UILabel *)createTipLabel:(CGRect)frame text:(NSString *)text superView:(UIView *)superView
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.font = FontNomal;
    label.text = text;
    label.textColor = ColorLightGray;
    [superView addSubview:label];
    return label;
}

/**
 * 发送按钮点击
 */
- (void)sendMsg
{
    if (self.isConnected) {
        // 连接状态 发送消息
        if (self.sendMsgBtnClick) {
            self.sendMsgBtnClick();
        }
    }else {
        // 断开状态 开始连接
        if (self.connectBtnClick) {
            self.connectBtnClick();
        }
    }
}

/**
 * 断开与服务器的连接
 */
- (void)disconnect
{
    if (self.disconnectBtnClick) {
        self.disconnectBtnClick();
    }
}

// 重写set方法
- (void)setIsConnected:(BOOL)isConnected
{
    _isConnected = isConnected;
    
    if (isConnected) {
        self.sendMsgBtn.titleText = @"发送消息给服务端";
        self.disconnectBtn.clickAble = YES;
    }else {
        self.sendMsgBtn.titleText = @"连接服务端";
        self.disconnectBtn.clickAble = NO;
    }
}

/**
 * 监听回车按钮
 */
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        // 发送
        [self sendMsg];
        return NO;
    }else {
        return YES;
    }
}

@end
