//
//  HYPlayDownloadVideoController.m
//  OCADV
//
//  Created by MrChen on 2019/1/19.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYPlayDownloadVideoController.h"
#import <AVKit/AVKit.h>

@interface HYPlayDownloadVideoController ()

// 删除按钮
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation HYPlayDownloadVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建播放视频视图
    [self createPlayViews];
}

#pragma mark - custom method

/**
 * 创建播放视频视图
 */
- (void)createPlayViews
{
    // 创建播放视频视图
    NSURL *vedioUrl = [NSURL fileURLWithPath:self.downloadMovieModel.savePath isDirectory:NO];
    AVPlayer *player = [[AVPlayer alloc]initWithURL:vedioUrl];
    AVPlayerViewController *playerCtr = [[AVPlayerViewController alloc]init];
    playerCtr.player = player;
    [self addChildViewController:playerCtr];
    // 获取视频尺寸
    [HYAVUtil getVideoNaturalSizeWithUrl:[NSURL URLWithString:self.downloadMovieModel.downloadUrl] complete:^(CGSize videoSize) {
        playerCtr.view.frame = CGRectMake(0, 0, ScWidth, (ScWidth / videoSize.width) * videoSize.height);
        playerCtr.view.center = self.view.center;
        self.deleteBtn.viewY = CGRectGetMaxY(playerCtr.view.frame);
    }];
    [self.bgView addSubview:playerCtr.view];

    // 创建删除按钮
    UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(playerCtr.view.frame), 30, 30)];
    deleteBtn.center = CGPointMake(self.view.center.x, deleteBtn.center.y + 10.0);
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteVedio) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
}

#pragma mark - click action
/**
 * 删除视频
 */
- (void)deleteVedio
{
    NSError *err = nil;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:self.downloadMovieModel.savePath error:&err];
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

@end
