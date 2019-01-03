//
//  RunloopController.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYRunloopController.h"
#import "HYRunloopModelController.h"
#import "HYRunloopLoadBigPicController.h"

/**
 * Runloop运行循环,保证线程不退出
 * 监听时钟、触摸、网络事件,没有事件处理就睡眠
 * 每条线程都有一个Runloop,主线程的Runloop在main函数的UIApplicationMain方法中被开启
 * 子线程的Runloop默认是不开启的,需要受到开启
 * Runloop
 */

@interface HYRunloopController ()

@end

@implementation HYRunloopController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = @[@{CELLTITLE:@"Runloop运行模式介绍",
                    CELLDESCRIPTION:@"Runloop五中运行模式介绍",
                    CONTROLLERNAME:@"HYRunloopModelController"},
                  @{CELLTITLE:@"Runloop解决TableViewCell加载大图片卡顿",
                    CELLDESCRIPTION:@"注册Runloop观察者来处理大图片的加载",
                    CONTROLLERNAME:@"HYRunloopLoadBigPicController"}];
}

@end
