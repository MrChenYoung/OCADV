//
//  SocketViewController.m
//  OCADV
//
//  Created by MrChen on 2018/12/5.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYSocketController.h"
#import "HYSocketServerCoreFApiController.h"
#import "HYSocketServerCocoaAsyncController.h"
#import "HYSocketClientCoreFApiController.h"
#import "HYSocketClientFApiController.h"
#import "HYSocketClientCocoaAsyncController.h"
#import "HYSocketServerFApiController.h"
#import "HYSocketServerWebController.h"
#import "HYSocketClientWebController.h"

/**
 * 电脑终端模拟socket服务端和客户端命令(mac系统)
 * 开启服务端：
 *      nc -lk <端口号> 释:nc-->Netcat终端下用于调试和检查网络的工具
 * 模拟客户端连接服务端:
 *      nc <要连接到服务端的ip> <要连接到服务端的端口号>
 */

@interface HYSocketController ()
@end

@implementation HYSocketController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.data = @[@{CELLTITLE:@"socket客户端",
                        CELLDESCRIPTION:@"苹果CoreFoundation框架API实现",
                        CONTROLLERNAME:@"HYSocketClientCoreFApiController"},
                      @{CELLTITLE:@"socket客户端",
                        CELLDESCRIPTION:@"苹果Foundation框架API实现",
                        CONTROLLERNAME:@"HYSocketClientFApiController"},
                      @{CELLTITLE:@"socket客户端",
                        CELLDESCRIPTION:@"CocoaAsyncSocket第三方框架实现",
                        CONTROLLERNAME:@"HYSocketClientCocoaAsyncController"},
                      @{CELLTITLE:@"webSocket客户端",
                        CELLDESCRIPTION:@"facebook开源框架SocketRocket实现",
                        CONTROLLERNAME:@"HYSocketClientWebController"},
                      @{CELLTITLE:@"socket服务端",
                        CELLDESCRIPTION:@"苹果CoreFoundation框架API实现",
                        CONTROLLERNAME:@"HYSocketServerCoreFApiController"},
                      @{CELLTITLE:@"socket服务端",
                        CELLDESCRIPTION:@"苹果Foundation框架API实现",
                        CONTROLLERNAME:@"HYSocketServerFApiController"},
                      @{CELLTITLE:@"socket服务端",
                        CELLDESCRIPTION:@"CocoaAsyncSocket第三方框架实现",
                        CONTROLLERNAME:@"HYSocketServerCocoaAsyncController"},
                      @{CELLTITLE:@"webSocket服务端",CELLDESCRIPTION:@"webSocket实现",
                        CONTROLLERNAME:@"HYSocketServerWebController"}];
}

@end
