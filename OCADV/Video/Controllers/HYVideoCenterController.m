//
//  HYVideoCenterController.m
//  OCADV
//
//  Created by MrChen on 2019/1/22.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoCenterController.h"
#import "HYVideoCategoryView.h"
#import "HYVideiListViewController.h"
#import "HYPlayVideoMoviePlayerController.h"

@interface HYVideoCenterController ()

@end

@implementation HYVideoCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"视频中心";
    
    // 添加子视图
    [self createSubviews];
}

#pragma mark - custom method
/**
 * 添加子视图
 */
- (void)createSubviews
{
    __weak typeof(self) weakSelf = self;
    
    // 本地视频
    HYVideoCategoryView *localVideoView = [[HYVideoCategoryView alloc]init];
    localVideoView.videoSource = @"本地视频";
    localVideoView.viewY = KNavigationBarH + KStatusBarH + 5.0;
    [self.view addSubview:localVideoView];
    // 点击回调
    __weak typeof(HYVideoCategoryView *) weakLocalView = localVideoView;
    localVideoView.tapBlock = ^{
        [weakSelf toVideoListControllerWithVideoSource:weakLocalView.videoSource videoModels:weakLocalView.videos];
    };
    // 播放视频
    localVideoView.playBlock = ^(HYVideoThumbnailView * _Nonnull thubnailView) {
        [weakSelf toPlayVideoControllerWithCategoryView:weakLocalView thubnailView:thubnailView];
    };
    // 加载本地视频
    [[HYGeneralSingleTon share]loadLocalVideosBlock:^(HYBaseVideoModel *model) {
        [localVideoView addVideoThumbnailImageViewWithModel:model];
    }];
    
    // 在线视频
    HYVideoCategoryView *onlineVideoView = [[HYVideoCategoryView alloc]init];
    onlineVideoView.videoSource = @"在线视频";
    onlineVideoView.viewY = CGRectGetMaxY(localVideoView.frame) + 10.0;
    // 点击回调
    __weak typeof(HYVideoCategoryView *) weakOnlineView = onlineVideoView;
    onlineVideoView.tapBlock = ^{
        [weakSelf toVideoListControllerWithVideoSource:weakOnlineView.videoSource videoModels:weakOnlineView.videos];
    };
    // 播放视频
    onlineVideoView.playBlock = ^(HYVideoThumbnailView * _Nonnull thubnailView) {
        [weakSelf toPlayVideoControllerWithCategoryView:weakOnlineView thubnailView:thubnailView];
    };
    // 加载在线视频
    [[HYGeneralSingleTon share] loadOnlineVideos];
    onlineVideoView.videos = [HYGeneralSingleTon share].onlineVideos;
    [self.view addSubview:onlineVideoView];
    
    // 直播回看
    HYVideoCategoryView *streamVideoView = [[HYVideoCategoryView alloc]init];
    streamVideoView.videoSource = @"直播回看";
    streamVideoView.viewY = CGRectGetMaxY(onlineVideoView.frame) + 10.0;
    // 点击回调
    __weak typeof(HYVideoCategoryView *) weakStreamView = streamVideoView;
    streamVideoView.tapBlock = ^{
        [weakSelf toVideoListControllerWithVideoSource:weakStreamView.videoSource videoModels:weakStreamView.videos];
    };
    // 播放视频
    streamVideoView.playBlock = ^(HYVideoThumbnailView * _Nonnull thubnailView) {
        [weakSelf toPlayVideoControllerWithCategoryView:weakStreamView thubnailView:thubnailView];
    };
    // 加载直播视频数据
    [[HYGeneralSingleTon share] loadStreamVideos];
    streamVideoView.videos = [HYGeneralSingleTon share].streamVideos;
    [self.view addSubview:streamVideoView];
}

/**
 * 进入视频列表页面
 */
- (void)toVideoListControllerWithVideoSource:(NSString *)videoSource videoModels:(NSArray <HYBaseVideoModel *>*)videoModels
{
    HYVideiListViewController *videoListCtr = [[HYVideiListViewController alloc]init];
    videoListCtr.videoSource = videoSource;
    videoListCtr.videosData = videoModels;
    [self.navigationController pushViewController:videoListCtr animated:YES];
}

/**
 * 进入视频播放页面
 */
- (void)toPlayVideoControllerWithCategoryView:(HYVideoCategoryView *)categoryView thubnailView:(HYVideoThumbnailView *)thubnailView
{
    HYPlayVideoMoviePlayerController *ctr = [[HYPlayVideoMoviePlayerController alloc]init];
    ctr.videoModel = thubnailView.model;
    CGRect rect = [categoryView convertRect:thubnailView.frame toView:self.view];
    ctr.fromReact = CGRectMake(rect.origin.x + rect.size.width * 0.5 - 5.0, rect.origin.y + rect.size.height * 0.5 + 10.0, 10.0, 10.0);
    ctr.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
    [self presentViewController:ctr animated:YES completion:nil];
}

@end
