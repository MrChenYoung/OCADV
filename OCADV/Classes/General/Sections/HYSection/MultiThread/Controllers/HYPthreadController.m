//
//  PthreadController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYPthreadController.h"
#import <pthread.h>

@interface HYPthreadController ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation HYPthreadController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.data = @[@{CELLTITLE:@"pthread多线程下载",
//                    CELLDESCRIPTION:@"多线程下载单个文件",
//                    CONTROLLERNAME:@"HYPthreadSingleFileController"},
//                  @{CELLTITLE:@"pthread多线程下载",
//                    CELLDESCRIPTION:@"多线程下载多个文件",
//                    CONTROLLERNAME:@"HYPthreadMultiFileController"}];
    
    NSArray *buttons = @[@"创建线程"];
    [HYCreateSubViewHandler createBtn:buttons fontSize:15 target:self sel:@selector(btnClick:) superView:self.view baseTag:1000];
}

- (void)btnClick:(UIButton *)btn
{
    NSInteger tag = btn.tag - 1000;
    switch (tag) {
        case 0:
            [self craetePthread];
            break;
            
        default:
            break;
    }
}

- (void)craetePthread
{
    // 用pthread创建线程
    pthread_t thread;
    NSString *params = @"pthreadAction";
    int result = pthread_create(&thread, NULL, &threadAction, (__bridge void *)(params));
    if (result != 0) {
        NSLog(@"创建线程失败");
    }
}

void *threadAction(void *data){
    NSLog(@"新建线程任务执行:%@,%@",[NSThread currentThread],data);
    
    return NULL;
}

@end
