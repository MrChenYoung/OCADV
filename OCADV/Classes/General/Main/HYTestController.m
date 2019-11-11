//
//  HYTestController.m
//  OCADV
//
//  Created by MrChen on 2019/2/6.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYTestController.h"
#import "HYMoviePlayerControllerUtil.h"

@interface HYTestController ()

@property (nonatomic, strong) HYMoviePlayerControllerUtil *playerCtr;

@property (nonatomic, assign) int index;
@end

@implementation HYTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.index = 10;
    self.playerCtr = [[HYMoviePlayerControllerUtil alloc]init];
    
    [self addPlayerView];
}

- (NSString *)loadUrl
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"m3u8Files1" ofType:nil];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *content = [str componentsSeparatedByString:@"%"];
    NSString *urlStr = content.lastObject;
    
    if (self.index < content.count) {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"*" withString:content[self.index]];
    }else {
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"*" withString:content[0]];
    }
    
    return urlStr;
}

- (void)addPlayerView
{
    NSString *url = [self loadUrl];
    UIView *playView = [self.playerCtr createVideoPlayerWithUrl:[NSURL URLWithString:url] autoPlay:NO];
    playView.frame = CGRectMake(0, 0, ScWidth, 300);
    playView.center = self.view.center;
    [self.view addSubview:playView];
    [self.playerCtr seekToTime:2];
}

@end
