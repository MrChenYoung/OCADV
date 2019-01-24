//
//  HYPlayVideoController.m
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYPlayVideoBaseController.h"


@interface HYPlayVideoBaseController ()

// 背景视图
@property (nonatomic, strong, readwrite) UIView *bgView;

// 播放器背景视图
@property (nonatomic, strong, readwrite) UIView *playerBgView;

// 加载菊花
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

// 播放按钮
@property (nonatomic, strong) UIButton *playButton;

// timer 用于控制控制播放控件的显示和自动隐藏
@property (nonatomic, strong) NSTimer *timer;

// 计时器数值
@property (nonatomic, assign) int timerCount;

@end

@implementation HYPlayVideoBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    self.videoModel.playStatus = videoPlayStatusLoadingThumbnail;
    [self createSubviews];
    
    // 设置控制播放block
    [self setControlBlock];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

#pragma mark - setter
/**
 * 是否显示自定义的播放控制视图
 */
- (void)setShowCustomControlViews:(BOOL)showCustomControlViews
{
    _showCustomControlViews = showCustomControlViews;
    
    [self createPlayControlViews];
    
    // 创建timer
    [self createTimer];
}

#pragma mark - lazy loading
/**
 * 播放视图
 */
- (UIView *)bgView
{
    if (_bgView == nil) {
        // 创建磨砂背景视图
        _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _bgView.backgroundColor = [UIColor clearColor];
        // 设置磨砂效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        blurEffectView.frame = _bgView.bounds;
        blurEffectView.alpha = 1;
        [_bgView insertSubview:blurEffectView atIndex:0];
    }
    
    return _bgView;
}

#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubviews
{
    // 添加背景视图
    [self.view addSubview:self.bgView];
    
    // 关闭页面按钮
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, KStatusBarH + 5.0, 30, 30)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:closeBtn];
}

/**
 * 创建播放控制视图
 */
- (void)createPlayControlViews
{
    // 播放器背景视图
    self.playerBgView = [[UIView alloc]init];
    [self.bgView addSubview:self.playerBgView];
    
    // 加载菊花
    self.loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.loadingView stopAnimating];
    [self.playerBgView addSubview:self.loadingView];
    
    // 播放按钮
    self.playButton = [[UIButton alloc]init];
    [self.playButton addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = YES;
    [self.playerBgView addSubview:self.playButton];
    
    [self updateControlViewFrames];
    [self updatePlayViewsStatus];
}

/**
 * 更新控制视图的frame
 */
- (void)updateControlViewFrames
{
    // 播放器背景视图frame
    self.playerBgView.frame = CGRectMake(0, 0, self.videoModel.naturalSize.width, self.videoModel.naturalSize.height);
    self.playerBgView.center = self.view.center;
    // 添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPlayer)];
    [self.playerBgView addGestureRecognizer:tap];
    
    CGSize playBgViewSize = self.playerBgView.bounds.size;
    CGPoint playBgViewCenterPoint = CGPointMake(playBgViewSize.width * 0.5, playBgViewSize.height * 0.5);
    
    // 加载菊花frame
    self.loadingView.center = playBgViewCenterPoint;
    
    // 播放按钮frame
    self.playButton.frame = CGRectMake(0, 0, 50, 50);
    self.playButton.center = playBgViewCenterPoint;
}

/**
 * 设置控制播放block
 */
- (void)setControlBlock
{
    __weak typeof(self) weakSelf = self;
    
    // 准备好播放
    self.preparedPlayBlock = ^{
        weakSelf.videoModel.playStatus = videoPlayStatusPrepared;
        [weakSelf updatePlayViewsStatus];
    };
}

/**
 * 根据model的状态更新view
 */
- (void)updatePlayViewsStatus
{
    switch (self.videoModel.playStatus) {
        case videoPlayStatusLoadingThumbnail:
            // 正在加载缩略图
            self.playButton.hidden = YES;
            [self.loadingView startAnimating];
            break;
        case videoPlayStatusLoadThumbnailComplete:
            // 缩略图加载完成
        case videoPlayStatusPrepared:
            // 准备好播放
            self.playButton.hidden = NO;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [self.loadingView stopAnimating];
            break;
        case videoPlayStatusPlaying:
            // 正在播放
            self.playButton.hidden = YES;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"pauseDownload"] forState:UIControlStateNormal];
            break;
        case videoPlayStatusPause:
            // 播放暂停
            self.playButton.hidden = NO;
            [self.playButton setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

/**
 * 创建timer
 */
- (void)createTimer
{
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timerCount = 0;
}

#pragma mark - click action
/**
 * 关闭页面
 */
- (void)close
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissComplete) {
            self.dismissComplete(NO);
        }
    }];
}

/**
 * 播放按钮点击
 */
- (void)playBtnClick
{
    switch (self.videoModel.playStatus) {
        case videoPlayStatusPrepared:
        case videoPlayStatusPause:
            // 开始播放
            if (self.playBlock) {
                self.playBlock();
                self.videoModel.playStatus = videoPlayStatusPlaying;
                [self updatePlayViewsStatus];
            }
            break;
        case videoPlayStatusPlaying:
            // 暂停播放
            if (self.pauseBlock) {
                self.pauseBlock();
                self.videoModel.playStatus = videoPlayStatusPause;
                [self updatePlayViewsStatus];
                [self.timer setFireDate:[NSDate distantFuture]];
            }
        default:
            break;
    }
}

/**
 * 点击播放view
 */
- (void)tapPlayer
{
    if (self.videoModel.playStatus == videoPlayStatusPlaying) {
        self.timerCount = 0;
        self.playButton.hidden = NO;
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

/**
 * 计时器action
 */
- (void)timerAction
{
    self.timerCount++;
    
    if (self.timerCount >= 3) {
        self.playButton.hidden = YES;
        self.timerCount = 0;
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

@end
