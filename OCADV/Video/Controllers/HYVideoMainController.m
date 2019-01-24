//
//  HYVideoPlayMainController.m
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideoMainController.h"
#import "HYVideoCategoryView.h"

@interface HYVideoMainController ()

@end

@implementation HYVideoMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频播放";
    
    self.data = @[@{CELLTITLE:@"AVPlayer",
                    CELLDESCRIPTION:@"使用AVPlayer播放视频",
                    CONTROLLERNAME:@"HYVideoCenterController"},
                  @{CELLTITLE:@"AVPlayerViewController",
                    CELLDESCRIPTION:@"使用AVPlayerViewController播放视频",
                    CONTROLLERNAME:@"HYVideoCenterController"},
                  @{CELLTITLE:@"MPMoviePlayerController",
                    CELLDESCRIPTION:@"使用MPMoviePlayerController播放视频",
                    CONTROLLERNAME:@"HYVideoCenterController"},
                  @{CELLTITLE:@"MPMoviePlayerViewController",
                    CELLDESCRIPTION:@"使用MPMoviePlayerViewController播放视频",
                    CONTROLLERNAME:@"HYVideoCenterController"}
                  ];
    
}

@end
