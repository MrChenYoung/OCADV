//
//  HYNetworkRequestMainController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYNetworkRequestMainController.h"

@interface HYNetworkRequestMainController ()

@end

@implementation HYNetworkRequestMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = @[@{CELLTITLE:@"NSURLConnection用法",
                    CELLDESCRIPTION:@"苹果早期提供的一套网络API(iOS7.0前主要的网络API,iOS9.0后被废弃)",
                    CONTROLLERNAME:@"HYURLConnectionController"},
                  @{CELLTITLE:@"NSURLSession用法",
                    CELLDESCRIPTION:@"苹果在iOS7.0后提供的一套API,iOS9.0后官方推荐使用",
                    CONTROLLERNAME:@"HYURLSessionController"
                    }];
}


@end
