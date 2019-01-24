//
//  HYBaseViewController.m
//  OCADV
//
//  Created by MrChen on 2019/1/21.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYBaseViewController.h"

@interface HYBaseViewController ()<UINavigationControllerDelegate>

@end

@implementation HYBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *root = navigationController.viewControllers[0];
    
    // 自定义返回按钮
    if (root != viewController) {
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        leftBtn.frame = CGRectMake(0, 0, 40,40);
        UIImage *img = [[UIImage imageNamed:@"nav_back"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [leftBtn setImage:img forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(popAction:) forControlEvents:UIControlEventTouchUpInside];
        leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    }
}

- (void)popAction:(UIBarButtonItem *)barButtonItem
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
