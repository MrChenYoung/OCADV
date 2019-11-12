//
//  SocketServerWebController.m
//  OCADV
//
//  Created by MrChen on 2018/12/18.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketServerWebController.h"
#import <SRWebSocket.h>

/**
 * 暂未找到webSocket的服务端实现,所以执行js文件来实现服务端
 */
@interface HYSocketServerWebController ()

@end

@implementation HYSocketServerWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"webSocket服务端";
    
    CGFloat x = 5;
    CGFloat y = KNavigationBarH + 5;
    CGFloat w = ScWidth - x * 2;
    CGFloat h = ScHeight - x - y;
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(x, y, w, h)];
    textView.editable = NO;
    textView.layer.borderWidth = 0.5;
    textView.layer.borderColor = ColorLightGray.CGColor;
    textView.layer.cornerRadius = 5;
    textView.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:textView];
    
    NSString *text = @"没有找到webSocket服务端代码,这里给出mac上用终端命令搭建webSocket测试服务端教程:\n1.安装Homebrew\n终端命令:ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"\n2.安装node\n终端命令:brew install node\n3.安装ws模块\n终端命令:npm install ws\n如果出现类似npm WARN enoent ENOENT: no such file or directory错误,使用命令:npm init -f修复\n4.执行项目中WSServer.js文件\n终端命令:node WSServer.js\n通过以上步骤就开启了监听本地6969端口的webSocket服务端。";
    textView.text = text;
}


@end
