//
//  HYPlayVideoMoviePlayerControllerViewController.m
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYPlayVideoMoviePlayerController.h"
#import "HYMoviePlayerControllerUtil.h"

@interface HYPlayVideoMoviePlayerController ()

// 播放器
@property (nonatomic, strong) HYMoviePlayerControllerUtil *playerController;

@end

@implementation HYPlayVideoMoviePlayerController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建播放视图
    self.showCustomControlViews = YES;
    [self createPlayViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.playerController stopPlay];
}

- (void)dealloc
{
    NSLog(@"播放器界面销毁");
}

#pragma mark - custom method
/**
 * 创建播放视图
 */
- (void)createPlayViews
{
    __weak typeof(self) weakSelf = self;
    self.playerController = [[HYMoviePlayerControllerUtil alloc]init];
    UIView *playerView = [self.playerController createVideoPlayerWithUrl:self.videoModel.url autoPlay:NO];
    [self.playerController seekToTime:self.videoModel.lastPlaySeconds];
    playerView.userInteractionEnabled = NO;
    [self.playerBgView insertSubview:playerView atIndex:0];
    
    // 准备好播放回调
    self.playerController.prepareToPlayBlock = ^{
        if (weakSelf.preparedPlayBlock) {
            weakSelf.preparedPlayBlock();
        }
    };
    
    // 播放回调
    self.playBlock = ^{
        [weakSelf.playerController play];
    };
    
    // 暂停播放回调
    self.pauseBlock = ^{
        [weakSelf.playerController pause];
    };
}


@end
