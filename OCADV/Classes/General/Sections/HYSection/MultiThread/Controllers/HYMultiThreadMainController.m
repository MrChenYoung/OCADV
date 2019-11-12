//
//  MultiThreadMainController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYMultiThreadMainController.h"

@interface HYMultiThreadMainController ()

@end

@implementation HYMultiThreadMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@{CELLTITLE:@"pthread",
                    CELLDESCRIPTION:@"跨平台的多线程开发框架",
                    CONTROLLERNAME:@"HYPthreadController"},
                  @{CELLTITLE:@"NSThread",
                    CELLDESCRIPTION:@"苹果原生封装框架",
                    CONTROLLERNAME:@"HYNSThreadController"},
                  @{CELLTITLE:@"GCD",
                    CELLDESCRIPTION:@"苹果提供的牛逼的并发开发框架",
                    CONTROLLERNAME:@"HYGCDController"},
                  @{CELLTITLE:@"NSOperation",
                    CELLDESCRIPTION:@"苹果基于GCD封装的面向对象并发开发技术",
                    CONTROLLERNAME:@"HYNSOperationController"},
                  ];
}

@end
