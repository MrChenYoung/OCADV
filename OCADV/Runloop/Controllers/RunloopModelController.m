//
//  RunloopModelController.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "RunloopModelController.h"

@interface RunloopModelController ()

// 开启计时器按钮
@property (nonatomic, strong) HYButton *timerBtn;

// 定时器
@property (nonatomic, strong) NSTimer *timer;

// 计数器当前计数
@property (nonatomic, assign) NSInteger timerIndex;

// 计数器当前计数显示label
@property (nonatomic, strong) UILabel *timerCountLabel;

@end

@implementation RunloopModelController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop运行模式介绍";

    // Runloop模式的使用
    [self useRunloopModel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

/**
 * Runloop模式的使用 共5种
 * NSDefaultRunLoopMode 默认模式,系统提供的默认运行模式
 * UITrackingRunLoopMode UI模式,处理UI任务(优先级高于默认模式)
 * NSRunLoopCommonModes 组合模式(占位模式),并不是一种真正的Runloop模式,而是同时注册了默认模式和UI模式
 * UIInitializationRunLoopMode 初始化模式 启动程序后的过渡mode，启动完成后就不再使用
 * GSEventReceiveRunLoopMode 内核模式 Graphic相关事件的mode，通常用不到
 */
- (void)useRunloopModel
{
    // 创建开启定时器按钮
    _timerBtn = [[HYButton alloc]init];
    _timerBtn.btnY = 44 + 20;
    _timerBtn.titleText = @"开启定时器";
    [_timerBtn addTarget:self action:@selector(createTimer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_timerBtn];
    
    // 创建textView滚动文字
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_timerBtn.frame) + 20, ScWidth - 20 * 2, 100)];
    textView.text = @"滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字滚动文字";
    textView.editable = false;
    [self.view addSubview:textView];
    
    // 显示定时器当前值label
    _timerCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(textView.frame) + 20, CGRectGetWidth(textView.frame), CGRectGetHeight(textView.frame))];
    _timerCountLabel.text = @"当前计数:0";
    [self.view addSubview:_timerCountLabel];
}

/**
 * 创建定时器
 */
- (void)createTimer
{
    if (_timer == nil) {
        // 选择定时器开启模式
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:@"选择模式" preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"NSDefaultRunLoopMode(默认模式)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startTimer:0];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"UITrackingRunLoopMode(UI模式)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startTimer:1];
            
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"NSRunLoopCommonModes(占位模式)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startTimer:2];
        }]];
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionSheet animated:YES completion:nil];
    }else {
        // 关闭定时器
        [_timer invalidate];
        _timer = nil;
        
        self.timerBtn.titleText = @"开启定时器";
    }
}

/**
 * 开启定时器
 */
- (void)startTimer:(NSInteger)model
{
    NSRunLoopMode runloopModel = NSDefaultRunLoopMode;
    switch (model) {
        case 0:
            runloopModel = NSDefaultRunLoopMode;
            break;
        case 1:
            runloopModel = UITrackingRunLoopMode;
            break;
        case 2:
            runloopModel = NSRunLoopCommonModes;
            break;
            
        default:
            break;
    }
    
    // 开启定时器
    self.timerIndex = 0;
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    
    /**
     * 添加定时器到当前Runloop中
     * 如果把定时器添加到NSDefaultRunLoopMode模式中,滚动文字的时候定时器会卡主
     * 如果把定时器加入UITrackingRunLoopMode模式中,只有滚动文字的时候定时器执行
     * 把定时器加入NSRunLoopCommonModes模式中,相当于同时在NSDefaultRunLoopMode和UITrackingRunLoopMode模式中加入定时器,解决定时器卡主问题
     */
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:runloopModel];
    
    self.timerBtn.titleText = @"关闭定时器";
    [(AppDelegate *)AppDelegateInstance showBottomTextViewDelay:@"定时器已开启,滚动文字查看定时器变化"];
}

/**
 * 定时器方法
 */
- (void)timerMethod
{
    self.timerIndex++;
    self.timerCountLabel.text = [NSString stringWithFormat:@"当前计数:%ld",(long)self.timerIndex];
}

@end
