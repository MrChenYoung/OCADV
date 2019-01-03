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

    self.data = @[@{CELLTITLE:@"NSThread多线程下载",
                    CELLDESCRIPTION:@"多线程下载单个文件",
                    CONTROLLERNAME:@"HYNSThreadSingleFileController"},
                  @{CELLTITLE:@"NSThread多线程下载",
                    CELLDESCRIPTION:@"多线程下载多个文件",
                    CONTROLLERNAME:@"HYNSThreadMultiFileController"}];
}


@end
