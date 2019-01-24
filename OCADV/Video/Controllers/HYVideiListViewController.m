//
//  HYVideiListViewController.m
//  OCADV
//
//  Created by MrChen on 2019/1/17.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYVideiListViewController.h"
#import "HYMovieModel.h"
#import "HYVideoListCell.h"
#import "HYPlayVideoMoviePlayerController.h"
#import "HYVideoThumbnailListController.h"

@interface HYVideiListViewController ()<UITableViewDelegate,UITableViewDataSource>

// 视频列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HYVideiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 加载视频数据
    [self reloadTitle];
    
    // 添加视频列表
    [self.view addSubview:self.tableView];
}

#pragma mark - custom method

/**
 * 刷新标题，显示加载进度
 */
- (void)reloadTitle
{
    int loadedThumbnailCount = 0;
    for (HYBaseVideoModel *model in self.videosData) {
        if (model.thumbnail != nil) {
            loadedThumbnailCount++;
        }
    }
    self.title = [NSString stringWithFormat:@"%@(%d/%lu)",self.videoSource,loadedThumbnailCount,(unsigned long)self.videosData.count];
}

#pragma mark - lazy loading
/**
 * 创建视频列表
 */
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videosData.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuserId = [NSString stringWithFormat:@"reuserId-%ld",(long)indexPath.row];
    HYVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYVideoListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }
    
    HYBaseVideoModel *model = self.videosData[indexPath.row];
    cell.model = model;
    cell.tapThumbnailBlock = ^{
        HYPlayVideoMoviePlayerController *ctr = [[HYPlayVideoMoviePlayerController alloc]init];
        ctr.videoModel = model;
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        ctr.fromReact = CGRectMake(rect.size.width * 0.5 - 5.0, rect.origin.y + rect.size.height * 0.5 - 5.0 - tableView.contentOffset.y, 10.0, 10.0);
        ctr.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
        [self presentViewController:ctr animated:YES completion:nil];
    };
    
    // 查看缩略图列表按钮点击回调
    cell.imageListBtnClickBlock = ^{
        HYVideoThumbnailListController *ctr = [[HYVideoThumbnailListController alloc]init];
        ctr.model = model;
        [self.navigationController pushViewController:ctr animated:YES];
    };
    
    // 加载缩略图完成回调
    cell.loadThumbnailComplete = ^{
        [self reloadTitle];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HYBaseVideoModel *model = self.videosData[indexPath.row];
    return model.naturalSize.height;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
