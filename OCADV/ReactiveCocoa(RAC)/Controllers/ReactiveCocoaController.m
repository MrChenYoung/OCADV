//
//  ReactiveCocoaController.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "ReactiveCocoaController.h"
#import "RACView.h"

@interface ReactiveCocoaController ()

@property (nonatomic, strong) RACView *racView;

@end

@implementation ReactiveCocoaController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"RAC用法";
    
    // 添加子视图
    self.racView = [[RACView alloc]init];
    [self.view addSubview:self.racView];
    
    // 订阅iRAC信号
    [self subscriptionRACSignal];
}

/**
 * 订阅RAC信号
 */
- (void)subscriptionRACSignal
{
    // RAC基本用法
    [self.racView.racSubject subscribeNext:^(id  _Nullable x) {
        [HYAlertUtil showAlertTitle:@"RAC基本使用" msg:x inCtr:self];
    }];
    
    // RAC简单用法
    [[self.racView rac_signalForSelector:@selector(simpleClick:)] subscribeNext:^(RACTuple * _Nullable x) {
        [HYAlertUtil showAlertTitle:@"RAC简单使用" msg:x.first inCtr:self];
    }];
}



@end
