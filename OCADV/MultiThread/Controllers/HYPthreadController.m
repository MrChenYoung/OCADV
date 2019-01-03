//
//  PthreadController.m
//  OCADV
//
//  Created by MrChen on 2018/12/19.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYPthreadController.h"

@interface HYPthreadController ()<UITableViewDataSource,UITableViewDelegate>


@end

@implementation HYPthreadController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.data = @[@{CELLTITLE:@"pthread多线程下载",
                    CELLDESCRIPTION:@"多线程下载单个文件",
                    CONTROLLERNAME:@"HYPthreadSingleFileController"},
                  @{CELLTITLE:@"pthread多线程下载",
                    CELLDESCRIPTION:@"多线程下载多个文件",
                    CONTROLLERNAME:@"HYPthreadMultiFileController"}];
}



@end
