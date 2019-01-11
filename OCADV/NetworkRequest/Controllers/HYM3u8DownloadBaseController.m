//
//  HYM3u8DownloadBaseController.m
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYM3u8DownloadBaseController.h"
#import "FFmpegManager.h"

@interface HYM3u8DownloadBaseController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

// 下载文件列表
@property (nonatomic, strong, readwrite) NSArray *downloadUrlArr;

@end

@implementation HYM3u8DownloadBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"m3u8视频下载";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // 下载列表
    NSMutableArray *arrM = [NSMutableArray array];
    NSTimeInterval timeInterval = [HYMoviesResolver share].m3u8TimeInterval;
    for (int i = 150; i < 200; i++) {
//        NSString *url = [NSString stringWithFormat:@"http://www.tszye.cn:2100/%d/500kb/hls/index.m3u8",i];
        NSString *url = [NSString stringWithFormat:@"http://101.96.10.75/letv.com-live-ko-com-kovin.com/%d/hls/index.m3u8",i];
        // 108435
//        NSString *url = @"https://dco4urblvsasc.cloudfront.net/811/81095_ywfZjAuP/game/1000kbps.m3u8";
        HYM3u8FileModel *model = [[HYM3u8FileModel alloc]init];
        model.timeInterval = timeInterval + i;
        model.downloadUrl = url;
        [arrM addObject:model];
    }
    
    self.downloadUrlArr = [arrM copy];
    [self.view addSubview:self.tableView];
}

#pragma mark - lazy loading
/**
 * 列表
 */
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    
    return _tableView;
}

#pragma mark - custom method
/**
 * 把所有的ts分片合成一个最终的ts文件
 */
- (void)mergeTs:(HYM3u8FileModel *)model progressBlock:(void (^)(double progress))progressBlock complete:(void (^)(void))complete
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:model.mergeTsFileSavePath]) {
        NSLog(@"文件已经存在，无需合并");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableData *resultData = [NSMutableData data];
        for (NSString *tsName in model.tsListsArray) {
            NSInteger index = [model.tsListsArray indexOfObject:tsName];
            NSString *tsPath = [model.tsSaveDir stringByAppendingPathComponent:tsName];
            NSData *tsData = [NSData dataWithContentsOfFile:tsPath];
            [resultData appendData:tsData];
            
            double pro = (double)(index + 1)/model.tsListsArray.count;
            // 主线程更新进度
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock) {
                    progressBlock(pro);
                }
            });
        }
        
        // 合并完成 写入硬盘
        [resultData writeToFile:model.mergeTsFileSavePath atomically:YES];
        
        // 主线程通知已经合成完成
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
        });
    });
}

/**
 * 转换合成以后的ts文件
 */
- (void)convertFileWithModel:(HYM3u8FileModel *)model progressBlock:(void (^)(double progress))progressBlock completeBlock:(void (^)(void))completeBlock
{
    [[FFmpegManager sharedManager] converWithInputPath:model.mergeTsFileSavePath outputPath:model.convertResultFilePath processBlock:^(float process) {
        if (progressBlock) {
            progressBlock(process);
        }
    } completionBlock:^(NSError *error) {
        if (completeBlock) {
            completeBlock();
        }
    }];
}

/**
 * 滚动到当前下载的行
 */
- (void)scrollToRow:(NSInteger)rowIndex
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**
 * 获取指定行的cell
 */
- (HYM3u8DownloadCell *)cellWithRowIndex:(NSInteger)rowIndex
{
    HYM3u8DownloadCell *cell = (HYM3u8DownloadCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0]];
    return cell;
}

#pragma mark - UITableViewDataSource
// row number
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadUrlArr.count;
}

// cell define code
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    static NSString *reuserId = @"reuserId";
    HYM3u8DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:reuserId];
    if (cell == nil) {
        cell = [[HYM3u8DownloadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuserId];
    }

    HYM3u8FileModel *model = self.downloadUrlArr[indexPath.row];
    cell.model = model;
    __weak typeof(HYM3u8DownloadCell *) weakCell = cell;
    cell.startDownloadBlock = ^(HYM3u8FileModel * _Nonnull model) {
        // 开始下载
        if (weakSelf.startDownloadBlock) {
            weakSelf.startDownloadBlock(model, weakCell);
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}

#pragma mark - UITableViewDelegate
// click row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

@end
