//
//  HYMoviePlayerControllerLocalCtr.m
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYMoviePlayerControllerLocalCtr.h"
#import "HYVideoThumbnailListCell.h"

@interface HYMoviePlayerControllerLocalCtr ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *thumbnailImages;

@end

@implementation HYMoviePlayerControllerLocalCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.thumbnailImages = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    
//    [self loadThumbnailImages];
    
    NSString *urlStr = @"http://www.streambox.fr/playlists/test_001/stream.m3u8";
    NSURL *url = [NSURL URLWithString:urlStr];
    [HYAVUtil getVideoLengthWithUrl:url complete:^(BOOL success, long long videoLength) {
        NSLog(@"获取到视频大小:%@",[NSByteCountFormatter stringFromByteCount:videoLength countStyle:NSByteCountFormatterCountStyleFile]);
    }];
    [HYAVUtil getVideoNaturalSizeWithUrl:url complete:^(CGSize videoSize) {
        NSLog(@"获取视频尺寸:%@",NSStringFromCGSize(videoSize));
    }];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

- (void)loadThumbnailImages
{
    NSString *urlStr = @"http://www.streambox.fr/playlists/test_001/stream.m3u8";
    [[HYAVUtil share] getStreamVideoThumbnailImage:[NSURL URLWithString:urlStr] time:5.0 complete:^(BOOL success, UIImage * _Nonnull image) {
        if (success) {
            [self.thumbnailImages addObject:image];
            [self.tableView reloadData];
        }else {
            NSLog(@"失败啦啦 1111111");
        }
    }];
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.thumbnailImages.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuserId = @"reuserId";
    HYVideoThumbnailListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYVideoThumbnailListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    
    UIImage *image = self.thumbnailImages[indexPath.row];
    if (image == nil) {
        [cell startLoading];
    }else {
        [cell stopLoading];
        cell.thumbnailImageView.viewSize = CGSizeMake(ScWidth, ScWidth / image.size.width * image.size.height);
        cell.thumbnailImageView.image = image;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = self.thumbnailImages[indexPath.row];
    return ScWidth / image.size.width * image.size.height;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
@end
