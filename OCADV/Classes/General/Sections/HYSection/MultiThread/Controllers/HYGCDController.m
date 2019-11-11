//
//  HYGCDController.m
//  OCADV
//
//  Created by MrChen on 2019/3/18.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYGCDController.h"

@interface HYGCDController ()

@end

@implementation HYGCDController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *buttons = @[@"在主线程同步执行串行队列任务",
                         @"在主线程同步执行并发队列任务",
                         @"在主线程异步执行串行队列任务",
                         @"在主线程异步执行并发队列任务",
                         @"在子线程同步执行串行队列任务",
                         @"在子线程同步执行并发队列任务",
                         @"在子线程异步执行串行队列任务",
                         @"在子线程异步执行并发队列任务",
                         @"在主线程同步执行全局并发队列任务",
                         @"在主线程异步执行全局并发队列任务",
                         @"在子线程同步执行全局并发队列任务",
                         @"在子线程异步执行全局并发队列任务"];
    [HYCreateSubViewHandler createBtn:buttons fontSize:15 target:self sel:@selector(btnClick:) superView:self.view baseTag:1000];
}

- (void)btnClick:(UIButton *)btn
{
    NSInteger tag = btn.tag - 1000;
    switch (tag) {
            // 在主线程同步执行串行队列任务
        case 0:
            [self synSerialOnMainThread];
            break;
            // 在主线程同步执行并发队列任务
        case 1:
            [self synConcurrentOnMainThread];
            break;
            // 在主线程异步执行串行队列任务
        case 2:
            [self asynSerialOnMainThread];
            break;
            // 在主线程异步执行并发队列任务
        case 3:
            [self asynConcurrentOnMainThread];
            break;
            // 在子线程同步执行串行队列任务
        case 4:
            [self performSelectorInBackground:@selector(synSerialOnChildThread) withObject:nil];
            break;
            // 在子线程同步执行并发队列任务
        case 5:
            [self performSelectorInBackground:@selector(synConcurrentOnChildThread) withObject:nil];
            break;
            // 在子线程异步执行串行队列任务
        case 6:
            [self performSelectorInBackground:@selector(asynSerialOnChildThread) withObject:nil];
            break;
            // 在子线程异步执行并发队列任务
        case 7:
            [self performSelectorInBackground:@selector(asynConcurrentOnChildThread) withObject:nil];
            break;
            // 在主线程同步执行全局并发队列任务
        case 8:
            [self synGlobal];
            break;
            // 在主线程异步执行全局并发队列任务
        case 9:
            [self performSelectorInBackground:@selector(synGlobal) withObject:nil];
            break;
            // 在子线程同步执行全局并发队列任务
        case 10:
            [self asynGlobal];
            break;
            // 在子线程异步执行全局并发队列任务
        case 11:
            [self performSelectorInBackground:@selector(asynGlobal) withObject:nil];
            break;
        default:
            break;
    }
}

/**
 * 在主线程同步执行串行队列任务
 * 所有任务在主线程有序执行
 */
- (void)synSerialOnMainThread
{
    [self synSerialLogMsg:@"同步执行串行队列" resultMessage:@"所有任务在主线程有序执行"];
}

/**
 * 在主线程同步执行并发队列任务
 * 所有任务在主线程有序执行
 */
- (void)synConcurrentOnMainThread
{
    [self synConcurrentLogMsg:@"同步执行并发队列" resultMessage:@"所有任务在主线程有序执行"];
}

/**
 * 在主线程异步执行串行队列任务
 * 只创建一条子线程,所有任务在子线程有序执行
 */
- (void)asynSerialOnMainThread
{
    [self asynSerialLogMsg:@"异步执行串行队列" resultMessage:@"只创建一条子线程,所有任务在子线程有序执行"];
}



/**
 * 在主线程异步执行并发队列任务
 * 创建多条子线程(线程数根据CPU和其他硬件决定),所有任务在不同的子线程无序执行
 */
- (void)asynConcurrentOnMainThread
{
    [self asynConcurrentLogMsg:@"异步执行串行队列" resultMessage:@"创建多条子线程(线程数根据CPU和其他硬件决定),所有任务在不同的子线程无序执行"];
}

/**
 * 在子线程同步执行串行队列任务
 * 所有任务在该子线程有序执行
 */
- (void)synSerialOnChildThread
{
    [self synSerialLogMsg:@"同步执行串行队列任务" resultMessage:@"所有任务在该子线程有序执行"];
}

/**
 * 在子线程同步执行并发队列任务
 * 所有任务在该子线程有序执行
 */
- (void)synConcurrentOnChildThread
{
    [self synConcurrentLogMsg:@"同步执行并发队列任务" resultMessage:@"所有任务在该子线程有序执行"];
}

/**
 * 在子线程异步执行串行队列任务
 * 只创建一条子线程，并在该线程有序执行所有任务
 */
- (void)asynSerialOnChildThread
{
    [self asynSerialLogMsg:@"异步执行串行队列任务" resultMessage:@"只创建一条子线程，并在该线程有序执行所有任务"];
}

/**
 * 在子线程异步执行并发队列任务
 * 创建多条子线程,所有任务在子线程上无序执行
 */
- (void)asynConcurrentOnChildThread
{
    [self asynConcurrentLogMsg:@"异步执行并发队列任务" resultMessage:@"创建多条子线程,所有任务在子线程上无序执行"];
}

// 同步执行串行队列任务
- (void)synSerialLogMsg:(NSString *)logMessage resultMessage:(NSString *)resultMessage
{
    // 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 添加任务到队列
    for (int i = 0; i < 10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@:%d,%@",logMessage,i,[NSThread currentThread]);
        });
    }
    NSLog(@"%@:%@",resultMessage,[NSThread currentThread]);
}

// 同步执行并发队列任务
- (void)synConcurrentLogMsg:(NSString *)logMessage resultMessage:(NSString *)resultMessage
{
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加任务到队列
    for (int i = 0; i < 10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@:%d,%@",logMessage,i,[NSThread currentThread]);
        });
    }
    NSLog(@"%@:%@",resultMessage,[NSThread currentThread]);
}

// 异步执行串行队列任务
- (void)asynSerialLogMsg:(NSString *)logMessage resultMessage:(NSString *)resultMessage
{
    // 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    
    // 添加任务到队列a
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@:%d,%@",logMessage,i,[NSThread currentThread]);
        });
    }
    NSLog(@"%@:%@",resultMessage,[NSThread currentThread]);
}

// 异步执行并发队列任务
- (void)asynConcurrentLogMsg:(NSString *)logMessage resultMessage:(NSString *)resultMessage
{
    // 创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加任务到队列a
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@:%d,%@",logMessage,i,[NSThread currentThread]);
        });
    }
    NSLog(@"%@:%@",resultMessage,[NSThread currentThread]);
}

/**
 * 同步执行全局并发队列任务
 * 所有任务在当前线程有序执行
 */
- (void)synGlobal
{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 添加任务到队列a
    for (int i = 0; i < 10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"同步执行全局并发队列任务:%d,%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"所有任务在当前线程有序执行:%@",[NSThread currentThread]);
}

/**
 * 异步执行全局并发队列任务
 * 创建多个线程,所有任务在不同的子线程无序执行
 */
- (void)asynGlobal
{
    // 获取全局并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 添加任务到队列a
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"异步执行全局并发队列任务:%d,%@",i,[NSThread currentThread]);
        });
    }
    NSLog(@"创建多个线程,所有任务在不同的子线程无序执行:%@",[NSThread currentThread]);
}

@end
