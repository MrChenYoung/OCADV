//
//  RunloopLoadBigPicController.m
//  OCADV
//
//  Created by MrChen on 2018/12/3.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "RunloopLoadBigPicController.h"
#import "BigPictureCell.h"

typedef void(^runloopTask)(void);

@interface RunloopLoadBigPicController ()<UITableViewDelegate,UITableViewDataSource>

// 优化开启按钮
@property (nonatomic, strong) HYButton *switchBtn;

// 是否开启大图优化
@property (nonatomic, assign) BOOL openLoadImg;

// 定时器
@property (nonatomic, strong) NSTimer *timer;

// 列表
@property (nonatomic, strong)UITableView *tableView;

// 任务队列
@property (nonatomic, strong) NSMutableArray *tasks;

// cell上imageview的高度
@property (nonatomic, assign) CGFloat cellImageH;

@end

@implementation RunloopLoadBigPicController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加子视图
    [self addSubViews];
    
    
    // 添加RunloopObserver
    [self addRunloopObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 销毁定时器
    [self.timer invalidate];
    self.timer = nil;
}

/**
 * 添加子视图
 */
- (void)addSubViews
{
    // 设置主视图
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop解决TableView卡顿问题";
    
    // 添加开启/关闭优化大图加载按钮
    HYButton *switchBtn = [[HYButton alloc]init];
    switchBtn.btnY = KStatusBarH + KNavigationBarH;
    switchBtn.titleText = @"开启大图加载优化";
    [switchBtn addTarget:self action:@selector(bigImgLoadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
    self.switchBtn = switchBtn;
    self.openLoadImg = NO;

    // 添加tableView
    self.tasks = [NSMutableArray array];
    _cellImageH = ScWidth/3;
    [self.view addSubview:self.tableView];
    
}

/**
 * 开启/关闭大图加载优化
 */
- (void)bigImgLoadBtnClick
{
    self.openLoadImg = !self.openLoadImg;
    
    if (self.openLoadImg) {
        self.switchBtn.titleText = @"关闭大图加载优化";
        [self openTimer];
    }else {
        self.switchBtn.titleText = @"开启大图加载优化";
        [self closeTimer];
    }
}

/**
 * 开启timer 保证Runloop不休眠
 */
- (void)openTimer
{
    if (self.timer == nil) {
        // 定时器 保证能够不停监听runloopObserver
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    }
    
    [self.timer setFireDate:[NSDate distantPast]];
}

/**
 * 关闭定时器
 */
- (void)closeTimer
{
    [self.timer setFireDate:[NSDate distantFuture]];
}


/**
 * 添加任务
 */
- (void)addTask:(runloopTask)task
{
    [self.tasks addObject:task];
}

/**
 * 定时器方法,保证能够不停添加任务
 */
- (void)timerMethod
{
    
}

/**
 * 添加Runloop的监听
 */
- (void)addRunloopObserver
{
    // 获取Runloop
    CFRunLoopRef runloopRef = CFRunLoopGetCurrent();
    
    // 创建context
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)self,
        &CFRetain,
        &CFRelease,
        NULL
    };
    
    // 创建observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(NULL,
                            kCFRunLoopBeforeWaiting,
                            YES,
                            NSIntegerMax - 999,
                            &callBack,
                            &context);
    
    // 在Runloop等待的时候监听
    // 这里使用默认的模式保证华东的时候不卡 如果使用kCFRunLoopCommonModes模式滑动的时候卡
    CFRunLoopAddObserver(runloopRef, observer, kCFRunLoopDefaultMode);
    
    // 释放观察者
    CFRelease(observer);
}

/**
 * 处理任务
 */
void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    RunloopLoadBigPicController *ctr = (__bridge RunloopLoadBigPicController *)info;
    if (ctr.tasks == 0) {
        return;
    }
    void (^task)(void) = ctr.tasks.firstObject;
    if (task != nil) {
        task();
        [ctr.tasks removeObjectAtIndex:0];
    }
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        CGFloat y = CGRectGetMaxY(self.switchBtn.frame) + 10;
        CGRect frame = CGRectMake(0, y, ScWidth, ScHeight - y);
        _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
// section number
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
//    BigPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
//    if (cell == nil) {
//        cell = [[BigPictureCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
//    }
    
    BigPictureCell *cell = [[BigPictureCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];

    // 移除cell上所有视图，重新创建添加，为了最大的消耗性能
    [cell.imageView1 removeFromSuperview];
    [cell.imageView2 removeFromSuperview];
    [cell.imageView3 removeFromSuperview];
    
    if (!self.openLoadImg) {
        // 关闭大图加载优化
        [cell addImageView1];
        [cell addImageView2];
        [cell addImageView3];
    }else {
        // 开启大图加载优化
        // 添加Runloop要处理的任务
        [self addTask:^{
            [cell addImageView1];
        }];
        [self addTask:^{
            [cell addImageView2];
        }];
        [self addTask:^{
            [cell addImageView3];
        }];
    }

    return cell;
}

// cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
