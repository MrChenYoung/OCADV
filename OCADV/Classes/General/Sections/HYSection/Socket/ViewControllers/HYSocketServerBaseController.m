//
//  SocketServerController.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketServerBaseController.h"
#import "HYSocketServerView.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <netinet/tcp.h>

@interface HYSocketServerBaseController ()

// 主视图
@property (nonatomic, strong) HYSocketServerView *serverView;

// socket
@property (nonatomic, assign) CFSocketRef socket;

@property (nonatomic, strong) NSMutableArray *addressArr;

@end

@implementation HYSocketServerBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Socket服务端";
    
    // 初始化socket
    [self initServerSocket];
    
    // 添加视图
    [self createSubViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 停止监听
    [self stopListen];
}

/**
 * 点击屏幕空白收起键盘
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/**
 * 初始化socket
 */
- (void)initServerSocket{}

/**
 * 开启监听指定端口
 */
- (void)startListen:(NSInteger)port{}

/**
 * 停止监听(关闭服务器)
 */
- (void)stopListen{}

/**
 * 发送消息
 */
- (void)sendMessage:(NSString *)message{}

/**
 * 收到消息
 */
- (void)recMessage:(NSString *)message
{
    NSString *text = self.serverView.recMessageTextView.text;
    text = [text stringByAppendingFormat:@"%@\n",message];
    self.serverView.recMessageTextView.text = text;
}

/**
 * 有新的客户端连接
 */
- (void)newClientConnect:(id)userData clientCount:(NSInteger)clientCount
{
    self.serverView.onlineClientsLabel.text = [NSString stringWithFormat:@"已连接的客户端(%ld)",(long)clientCount];
    NSString *conStr = self.serverView.onlineClientsTextView.text;
    conStr = [conStr stringByAppendingFormat:@"新客户端连接:%@\n",userData];
    self.serverView.onlineClientsTextView.text = conStr;
}

/**
 * 客户端断开连接
 */
- (void)clientDisconnect:(id)userData clientCount:(NSInteger)clientCount
{
    self.serverView.onlineClientsLabel.text = [NSString stringWithFormat:@"已连接的客户端(%ld)",(long)clientCount];
    NSString *conStr = self.serverView.onlineClientsTextView.text;
    conStr = [conStr stringByAppendingFormat:@"有客户端断开连接:%@\n",userData];
    self.serverView.onlineClientsTextView.text = conStr;
}


/**
 * 添加视图
 */
- (void)createSubViews
{
    __weak typeof(self) weakSelf = self;
    self.serverView = [[HYSocketServerView alloc]init];
    // 开始监听
    self.serverView.startListenCallBack = ^{
        // 开启监听
        [weakSelf startListen:[weakSelf.serverView.portTextView.text intValue]];
    };
    
    // 停止监听
    self.serverView.stopListenCallBack = ^{
        [weakSelf stopListen];
    };
    
    // 发送消息
    self.serverView.sendMessageCallBack = ^{
        NSString *msg = weakSelf.serverView.sendMessageTextView.text;
        if (msg == nil || msg.length == 0) {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"消息不能为空" inCtr:weakSelf];
            return ;
        }
        
        [weakSelf sendMessage:weakSelf.serverView.sendMessageTextView.text];
        weakSelf.serverView.sendMessageTextView.text = @"";
    };
    
    [self.view addSubview:self.serverView];
}


/**
 * 开启监听结果处理
 */
- (void)startListenResultHandle:(BOOL)success
{
    if (success) {
        // 开启监听成功
        self.serverView.isListening = YES;
    }else {
        // 开启监听失败
        self.serverView.isListening = NO;
        [HYAlertUtil showAlertTitle:@"提示" msg:@"服务端开启失败" inCtr:self];
    }
}

/**
 * 关闭监听结果处理
 */
- (void)stopListenResultHandle:(BOOL)success
{
    if (success) {
        // 关闭监听成功
        self.serverView.isListening = NO;
    }else {
        // 关闭监听失败
        self.serverView.isListening = YES;
    }
}

@end
