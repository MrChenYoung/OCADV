//
//  HYMainView.m
//  OCADV
//
//  Created by MrChen on 2019/3/2.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYMainView.h"

@interface HYMainView ()

// scroll
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation HYMainView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = ScBounds;
        self.backgroundColor = [UIColor whiteColor];
        
        // 添加子视图
        [self setupSubviews];
    }
    return self;
}

#pragma mark - 设置子视图
- (void)setupSubviews
{
    // scrollView
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.bounds];
    [self addSubview:scroll];
    self.scrollView = scroll;
    
    self.weatherView = [[HYWeatherView alloc]init];
    [self.scrollView addSubview:self.weatherView];
}



@end
