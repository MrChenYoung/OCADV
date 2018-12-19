//
//  SocketClientController.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketClientBaseController.h"


@interface SocketClientBaseController ()
// 客户端view
@property (nonatomic, strong) SocketClientView *clientView;

@end

@implementation SocketClientBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"socket客户端";
    
    // 创建子视图
    __weak typeof(self) weakSelf = self;
    self.clientView = [[SocketClientView alloc]init];
    // 连接服务器
    self.clientView.connectBtnClick = ^{
        // 建立连接
        NSString *serverIp = weakSelf.clientView.ipTextView.text;
        NSInteger serverPort = [weakSelf.clientView.portTextView.text integerValue];
        [weakSelf connectionToServer:serverIp port:serverPort];
    };
    // 断开服务器连接
    self.clientView.disconnectBtnClick = ^{
        [weakSelf disconnect];
    };
    
    // 给服务器发送消息
    self.clientView.sendMsgBtnClick = ^{
        // 已经连接,发送消息
        [weakSelf sendMessage:weakSelf.clientView.messageTextView.text];
    };
    [self.view addSubview:self.clientView];
    
    // 初始化socket
    [self initSocket];
}

/**
 * 点击屏幕空白收起键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/**
 * 收到消息
 */
- (void)receiveMessage:(NSString *)message
{
    if (message == nil || message.length == 0) return;
    
    NSString *msg = message;
    NSString *str = self.clientView.recTextView.text;
    NSString *lastStr = [msg substringFromIndex:msg.length - 1];
    if (![lastStr isEqualToString:@"\n"]) {
        msg = [msg stringByAppendingString:@"\n"];
    }
    str = [str stringByAppendingString:[NSString stringWithFormat:@"%@",msg]];
    self.clientView.recTextView.text = str;
}

/**
 * 初始化socket
 */
- (void)initSocket{}

/**
 * 连接服务端
 */
- (void)connectionToServer:(NSString *)serverIP port:(NSInteger)port
{
     [self showLoadingView:@"连接中..."];
}

/**
 * 断开与服务器的连接
 */
- (void)disconnect
{
    [self showLoadingView:@"正在断开服务器..."];
}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message
{
    if (message == nil || message.length == 0) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"发送的消息不能为空" inCtr:self];
        return;
    }
    
    [self showLoadingView:@"发送中..."];
}

/**
 * 连接服务端结果处理
 */
- (void)connetResultHandle:(BOOL)result
{
    [self hiddenLoadingView];
    self.clientView.isConnected = result;
    
    if (result) {
        // 连接成功
        NSLog(@"连接服务器成功");
    }else {
        // 连接失败
        NSString *message = @"连接服务端失败";
        [HYAlertUtil showAlertTitle:@"提示" msg:message inCtr:self];
    }
}

/**
 * 断开连接服务端结果处理
 */
- (void)disconnetResultHandle:(BOOL)result
{
    [self hiddenLoadingView];
    
    self.clientView.isConnected = !result;
    
    if (result) {
        
    }else {
        NSLog(@"断开连接服务器失败");
        [HYAlertUtil showAlertTitle:@"提示" msg:@"断开服务器连接失败" inCtr:self];
    }
}

/**
 * 发送消息结果处理
 */
- (void)sendMessageResultHandle:(BOOL)result
{
    [self hiddenLoadingView];
    
    if (!result) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"消息发送失败" inCtr:self];
    }else {
        // 发送消息成功，清空输入框
        self.clientView.messageTextView.text = @"";
    }
}

/**
 * 服务器断开连接
 */
- (void)serverDisconnectHandle
{
    self.clientView.isConnected = NO;
    [HYAlertUtil showAlertTitle:@"提示" msg:@"服务器断开连接" inCtr:self];
}

/**
 * 显示loadingview
 */
- (void)showLoadingView:(NSString *)title
{
    [self.clientView.sendMsgBtn showLoadingView:title];
}

/**
 * 隐藏loadingView
 */
- (void)hiddenLoadingView
{
    [self.clientView.sendMsgBtn hiddenLoadingView];
}

@end
