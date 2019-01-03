//
//  RACView.m
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYRACView.h"

@interface HYRACView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation HYRACView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScWidth, ScHeight);
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.contentSize = CGSizeMake(ScWidth, ScHeight);
        self.scrollView.delegate = self;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenKeyboard)];
        [self.scrollView addGestureRecognizer:gesture];
        [self addSubview:self.scrollView];
        [self createSubViews];
    }
    return self;
}

/**
 * 信号提供者
 */
- (RACSubject *)racSubject
{
    if (_racSubject == nil) {
        _racSubject = [RACSubject subject];
    }
    
    return _racSubject;
}

/**
 * 创建子视图
 */
- (void)createSubViews
{
    CGFloat w = ScWidth * 0.9;
    CGFloat h = 40;
    CGFloat x = ScWidth * 0.1 * 0.5;
    CGFloat yMagrin = 20;
    
    // RAC基本用法
    CGRect baseBtnFrame = CGRectMake(x, yMagrin, w, h);
    [self createButton:baseBtnFrame title:@"RAC基本用法" selector:@selector(RACBaseBtnClick)];
    
    // RAC简单用法
    CGRect simpleBtnFrame = CGRectMake(x, CGRectGetMaxY(baseBtnFrame) + 10, w, h);
    [self createButton:simpleBtnFrame title:@"RAC简单用法" selector:@selector(RACSimpleBtnClick)];
    
    // RAC监听按钮的点击事件
    CGRect monitorClickFrame = CGRectMake(x, CGRectGetMaxY(simpleBtnFrame) + 10, w, h);
    UIButton *monitorBtn = [self createButton:monitorClickFrame title:@"RAC监听按钮点击" selector:nil];
    [[monitorBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [HYAlertUtil showAlertTitle:@"RAC监听按钮点击" msg:@"RAC监听的按钮点击了" inCtr:[ControllerUtil topViewController]];
        
        // 返回的参数是monitorBtn本身
        NSLog(@"%@",x);
    }];
    
    // 输入框
    UITextField *textFiled = [[UITextField alloc]initWithFrame:CGRectMake(x, CGRectGetMaxY(monitorClickFrame) + 10, w, h)];
    textFiled.layer.borderWidth = 0.5;
    textFiled.layer.borderColor = [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1.0].CGColor;
    textFiled.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    textFiled.leftViewMode = UITextFieldViewModeAlways;
    textFiled.placeholder = @"请输入文字";
    textFiled.font = [UIFont systemFontOfSize:14];
    [self.scrollView addSubview:textFiled];
    
    // RAC监听通知
    [self RACMonitorNotification];
    
    // RAC监听输入框文字变化
    [textFiled.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        // 文字变化
        [(AppDelegate *)AppDelegateInstance showBottomTextViewDelay:[NSString stringWithFormat:@"输入文字改变:%@",x]];
        NSLog(@"输入框文字变化:%@",x);
    }];
    
    // RAC定时器
    CGRect openTimerFrame = CGRectMake(x, CGRectGetMaxY(textFiled.frame) + 10, w, h);
    UIButton *openTimerBtn = [self createButton:openTimerFrame title:@"开启RAC定时器" selector:nil];
    CGRect closeTimerFrame = CGRectMake(x, CGRectGetMaxY(openTimerFrame) + 10, w, h);
    UIButton *closeTimerBtn = [self createButton:closeTimerFrame title:@"关闭RAC定时器" selector:nil];
    
    // 开启定时器
    __block RACDisposable *disposable = nil;
    __block NSInteger number = 0;
    [[openTimerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [(AppDelegate *)AppDelegateInstance showBottomTextView:@"定时器已开启"];
        
        // 开启定时器(scheduler在子线程执行 mainThreadScheduler在主线程执行)
        // 设置takeUntil 当控制器消失的时候停止定时器
        RACSignal *timerStopSignal = [[self getCurrentViewController] rac_signalForSelector:@selector(viewWillDisappear:)];
        disposable = [[[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:timerStopSignal] subscribeNext:^(NSDate * _Nullable x) {
            number++;
            [(AppDelegate *)AppDelegateInstance updateBottomTextView:[NSString stringWithFormat:@"%ld",(long)number]];
        }];
    }];
    
    // 关闭定时器
    [[closeTimerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (![disposable isDisposed]) {
            [disposable dispose];
            [(AppDelegate *)AppDelegateInstance updateBottomTextView:@"定时器已关闭"];
            [(AppDelegate *)AppDelegateInstance hiddenBottomTextView];
        }
    }];
}

/**
 * RAC基本用法按钮点击事件
 */
- (void)RACBaseBtnClick
{
    // 发送信号
    [self.racSubject sendNext:@"RAC基本用法按钮点击"];
}

/**
 * RAC简单用法按钮点击事件
 */
- (void)RACSimpleBtnClick
{
    [self simpleClick:@"RAC简单用法按钮点击"];
}

- (void)simpleClick:(NSString *)string
{
    
}

/**
 * RAC监听通知(监听键盘的弹出和隐藏)
 */
- (void)RACMonitorNotification
{
    // 监听键盘弹出
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [(AppDelegate *)AppDelegateInstance showBottomTextViewDelay:@"键盘弹出"];
        NSLog(@"键盘弹出:%@",x.userInfo);
    }];
    
    // 监听键盘消失
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [(AppDelegate *)AppDelegateInstance showBottomTextViewDelay:@"键盘收起"];
        NSLog(@"键盘消失:%@",x.userInfo);
    }];
}

/**
 * 创建按钮
 */
- (UIButton *)createButton:(CGRect)frame title:(NSString *)title selector:(SEL)selector
{
    UIButton *btn = [[UIButton alloc]initWithFrame:frame];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.backgroundColor = [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1];
    [btn setTitle:title forState:UIControlStateNormal];
    if (selector != nil) {
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.scrollView addSubview:btn];

    return btn;
}

/**
 * 隐藏键盘
 */
- (void)hiddenKeyboard
{
    [self endEditing:YES];
}

- (void)dealloc
{
    
}

@end
