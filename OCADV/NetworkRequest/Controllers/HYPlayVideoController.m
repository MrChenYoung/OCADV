//
//  HYPlayVideoController.m
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYPlayVideoController.h"
#import "HYTransitionAnimation.h"
//#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface HYPlayVideoController ()<UIViewControllerTransitioningDelegate>

// 播放视频背景视图
@property (nonatomic, strong) UIView *playBgView;

@end

@implementation HYPlayVideoController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    [self createSubviews];
}

#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubviews
{
    // 添加背景视图
    [self.view addSubview:self.playBgView];
    
    // 关闭页面按钮
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, KStatusBarH + 5.0, 30, 30)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.playBgView addSubview:closeBtn];
    
    // 创建播放视频视图
    NSURL *vedioUrl = [NSURL fileURLWithPath:[HYMoviesResolver share].netDownloadFileSavePath isDirectory:NO];
    AVPlayer *player = [[AVPlayer alloc]initWithURL:vedioUrl];
    AVPlayerViewController *playerCtr = [[AVPlayerViewController alloc]init];
    playerCtr.player = player;
    CGSize videoSize = [self getVideoSize];
    playerCtr.view.frame = CGRectMake(0, 0, ScWidth, (ScWidth / videoSize.width) * videoSize.height);
    playerCtr.view.center = self.view.center;
    [self addChildViewController:playerCtr];
    [self.playBgView addSubview:playerCtr.view];
    
    // 删除按钮
    UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(playerCtr.view.frame), 30, 30)];
    deleteBtn.center = CGPointMake(self.view.center.x, deleteBtn.center.y + 10.0);
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playBgView addSubview:deleteBtn];
}

/**
 * 获取视频的尺寸
 */
- (CGSize)getVideoSize
{
    //获取视频尺寸
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[HYMoviesResolver share].netDownloadFileSavePath]];
    NSArray *array = asset.tracks;
    CGSize videoSize = CGSizeZero;
    for (AVAssetTrack *track in array) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoSize = track.naturalSize;
        }
    }
    
    return videoSize;
}

#pragma mark - lazy loading
/**
 * 播放视图
 */
- (UIView *)playBgView
{
    if (_playBgView == nil) {
        // 创建磨砂背景视图
        _playBgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _playBgView.backgroundColor = [UIColor clearColor];
        // 设置磨砂效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        blurEffectView.frame = _playBgView.bounds;
        blurEffectView.alpha = 1;
        [_playBgView insertSubview:blurEffectView atIndex:0];
    }
    
    return _playBgView;
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
 * 删除视频
 */
- (void)deleteClick
{
    NSError *err = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[HYMoviesResolver share].netDownloadFileSavePath error:&err];
    if (!success || err) {
        // 删除本地视频失败
        [HYToast toastWithMessage:@"视频删除失败"];
    }else{
        // 视频删除成功
        [HYToast toastWithMessage:@"视频已删除"];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismissComplete) {
                self.dismissComplete(YES);
            }
        }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [HYTransitionAnimation transitionWithTransitionType:TransitionAnimationTypePresent fromReact:self.fromReact];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [HYTransitionAnimation transitionWithTransitionType:TransitionAnimationTypeDismiss fromReact:self.fromReact];
}

@end
