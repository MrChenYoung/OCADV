//
//  SocketServerView.m
//  OCADV
//
//  Created by MrChen on 2018/12/6.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "SocketServerView.h"
#import "SocketClientView.h"

@interface SocketServerView ()

// 滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

// 监听/发送消息按钮
@property (nonatomic, strong) HYButton *sendMessageBtn;

// 停止监听(关闭服务器)按钮
@property (nonatomic, strong) HYButton *stopListenBtn;

@end

@implementation SocketServerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect frame = CGRectMake(0, 0, ScWidth, ScHeight);
        self.frame = frame;
    
        // 添加子视图
        [self createSubViews];
    }
    return self;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.frame = CGRectMake(0, KNavigationBarH + 5, ScWidth, self.bounds.size.height - KNavigationBarH - 5);
    [self addSubview:self.scrollView];
    
    CGRect ipPortFrame = CGRectMake(10, 0, ScWidth - 20, 30);
    [SocketClientView createTipLabel:ipPortFrame text:@"监听的端口:" superView:self.scrollView];
    
    // 监听的端口号
    CGRect portFrame = CGRectMake(10, CGRectGetMaxY(ipPortFrame) + 5, ScWidth - 20, 30);
    _portTextView = [SocketClientView createInputTextFiled:portFrame placeHold:@"输入要监听的端口" superView:self.scrollView];
    _portTextView.text = [NSString stringWithFormat:@"%d",SERVERPORT];
    
    //连接的客户端
    CGRect onlineClientsTipFrame = CGRectMake(10, CGRectGetMaxY(portFrame) + 10, ScWidth - 20, 30);
    _onlineClientsLabel = [SocketClientView createTipLabel:onlineClientsTipFrame text:@"已连接的客户端(0):" superView:self.scrollView];
    CGRect onlineClientsFrame = CGRectMake(10, CGRectGetMaxY(onlineClientsTipFrame) + 5, ScWidth - 20, ScHeight * 0.2);
    _onlineClientsTextView = [SocketClientView createInputTextFiled:onlineClientsFrame placeHold:@"暂无客户端连接" superView:self.scrollView];
    _onlineClientsTextView.editable = NO;
    
    // 接受客户端发送来的消息
    CGRect recMessageTipFrame = CGRectMake(10, CGRectGetMaxY(onlineClientsFrame) + 10, ScWidth - 20, 30);
    [SocketClientView createTipLabel:recMessageTipFrame text:@"接收到的消息:" superView:self.scrollView];
    CGRect recMessageFrame = CGRectMake(10, CGRectGetMaxY(recMessageTipFrame) + 5, ScWidth - 20, ScHeight * 0.2);
    _recMessageTextView = [SocketClientView createInputTextFiled:recMessageFrame placeHold:@"暂无客户端消息" superView:self.scrollView];
    _recMessageTextView.editable = NO;
    
    // 发送消息给客户端
    CGRect sendMessageTipFrame = CGRectMake(10, CGRectGetMaxY(recMessageFrame) + 10, ScWidth - 20, 30);
    [SocketClientView createTipLabel:sendMessageTipFrame text:@"发送消息给客户端:" superView:self.scrollView];
    CGRect sendMessageFrame = CGRectMake(10, CGRectGetMaxY(sendMessageTipFrame) + 5, ScWidth - 20, ScHeight * 0.2);
    _sendMessageTextView = [SocketClientView createInputTextFiled:sendMessageFrame placeHold:@"输入要发送给客户端的消息" superView:self.scrollView];
    
    // 监听/发送消息按钮
    _sendMessageBtn = [[HYButton alloc]init];
    _sendMessageBtn.btnY = CGRectGetMaxY(sendMessageFrame) + 10;
    _sendMessageBtn.titleText = @"开始监听";
    [_sendMessageBtn addTarget:self action:@selector(startListen) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_sendMessageBtn];
    
    // 停止监听(关闭服务器)按钮
    _stopListenBtn = [[HYButton alloc]init];
    _stopListenBtn.btnY = CGRectGetMaxY(_sendMessageBtn.frame) + 10;
    _stopListenBtn.titleText = @"停止监听";
    _stopListenBtn.clickAble = NO;
    [_stopListenBtn addTarget:self action:@selector(stopListen) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_stopListenBtn];
    
    self.scrollView.contentSize = CGSizeMake(ScWidth, CGRectGetMaxY(_stopListenBtn.frame) + 10);
}

// 开始监听/发送消息
- (void)startListen
{
    if (_isListening) {
        // 已经在监听，发送消息
        if (self.sendMessageCallBack) {
            self.sendMessageCallBack();
        }
    }else {
        // 开始监听
        if (self.startListenCallBack) {
            self.startListenCallBack();
        }
    }
}

// 重写set方法处理逻辑，修改界面
- (void)setIsListening:(BOOL)isListening
{
    _isListening = isListening;
    
    if (isListening) {
        // 已经开启监听
        self.sendMessageBtn.titleText = @"发送消息给所有的客户端";
        self.stopListenBtn.clickAble = YES;
    }else {
        // 关闭监听
        self.sendMessageBtn.titleText = @"开始监听";
        self.stopListenBtn.clickAble = NO;
    }
}

// 停止监听
- (void)stopListen
{
    if (self.stopListenCallBack) {
        self.stopListenCallBack();
    }
}

@end
