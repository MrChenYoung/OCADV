//
//  ViewController.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

// 列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"iOS高级开发";
    
    // 初始化列表数据
    self.data = @[@{CELLTITLE:@"ReactiveCocoa(RAC)",
                    CELLDESCRIPTION:@"函数响应式编程应用",
                    CONTROLLERNAME:@"HYReactiveCocoaController"},
                  @{CELLTITLE:@"Runtime原理探索",
                    CELLDESCRIPTION:@"运行时原理用法探索",
                    CONTROLLERNAME:@"HYRuntimeController"},
                  @{CELLTITLE:@"Runloop原理探索",
                    CELLDESCRIPTION:@"运行循环剖析",
                    CONTROLLERNAME:@"HYRunloopController"},
                  @{CELLTITLE:@"Socket编程",
                    CELLDESCRIPTION:@"即时通讯常用技术",
                    CONTROLLERNAME:@"HYSocketController"},
                  @{CELLTITLE:@"多线程开发",
                    CELLDESCRIPTION:@"多线程开发常用技能介绍",
                    CONTROLLERNAME:@"HYMultiThreadMainController"},
                  @{CELLTITLE:@"网络请求篇",
                    CELLDESCRIPTION:@"网络请求技术详解",
                    CONTROLLERNAME:@"HYNetworkRequestMainController"},
                  @{CELLTITLE:@"视频播放",
                    CELLDESCRIPTION:@"本地视频和在线视频的播放",
                    CONTROLLERNAME:@"HYVideoMainController"}
                  ];
}

@end
