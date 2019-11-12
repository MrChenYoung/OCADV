//
//  NSThreadController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYNSThreadController.h"

@interface HYNSThreadController ()

@end

@implementation HYNSThreadController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.data = @[@{CELLTITLE:@"NSThread多线程下载",
//                    CELLDESCRIPTION:@"多线程下载单个文件",
//                    CONTROLLERNAME:@"HYNSThreadSingleFileController"},
//                  @{CELLTITLE:@"NSThread多线程下载",
//                    CELLDESCRIPTION:@"多线程下载多个文件",
//                    CONTROLLERNAME:@"HYNSThreadMultiFileController"}];
    
    NSArray *buttons = @[@"创建线程方式一",@"创建线程方式二",@"创建线程方式三",@"创建线程方式四",@"创建线程方式五"];
    [HYCreateSubViewHandler createBtn:buttons fontSize:15 target:self sel:@selector(btnClick:) superView:self.view baseTag:1000];
}

- (void)btnClick:(UIButton *)btn
{
    NSInteger tag = btn.tag - 1000;
    switch (tag) {
        case 0:{
            // 创建线程方式一
            NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(demo:) object:@"createThread1"];
            [thread start];
        }
            break;
            
            // 创建线程方式二
        case 1:{
            NSThread *thread = [[NSThread alloc]initWithBlock:^{
                [self demo:@"createThread2"];
            }];
            [thread start];
        }
            break;
            // 创建线程方式三
        case 2:{
            [NSThread detachNewThreadSelector:@selector(demo:) toTarget:self withObject:@"createThread3"];
        }
            break;
            // 创建线程方式四
        case 3:{
            [NSThread detachNewThreadWithBlock:^{
                [self demo:@"createThread4"];
            }];
        }
            break;
            // 创建线程方式五
        case 4:{
            [self performSelectorInBackground:@selector(demo:) withObject:@"createThread5"];
        }
            break;
        default:
            break;
    }
}

- (void)demo:(id)args
{
    NSLog(@"新建线程:%@,%@",[NSThread currentThread],args);
}


@end
