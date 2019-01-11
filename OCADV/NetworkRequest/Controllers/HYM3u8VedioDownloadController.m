//
//  HYM3u8VedioDownloadController.m
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYM3u8VedioDownloadController.h"
#import "HYURLConnectionDownload.h"

@interface HYM3u8VedioDownloadController ()

@end

@implementation HYM3u8VedioDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    // 开始下载回调
    self.startDownloadBlock = ^(HYM3u8FileModel * _Nonnull model, HYM3u8DownloadCell * _Nonnull cell) {
        // 开始下载m3u8文件
        NSLog(@"开始下载文件,存储路径:%@",model.originalSavePath);
        [weakSelf downloadOriginalU3m8:model cell:cell];
    };
}

/**
 * 下载源m3u8文件
 */
- (void)downloadOriginalU3m8:(HYM3u8FileModel *)model cell:(HYM3u8DownloadCell *)cell
{
    __weak typeof(self) weakSelf = self;
    // 通过设置数据model更新view
    model.status = downloadStatusGettingFrames;
    cell.model = model;
    
    // 开始下载
    [[HYURLConnectionDownload share] downloadFile:model.downloadUrl savePath:model.originalSavePath didReceiveResponse:^(long long totalSize, NSString * _Nonnull fileName) {
        model.fileName = fileName;
        model.totalLength = totalSize;
        cell.model = model;
        NSLog(@"获取到服务器返回信息:%lld,%@",totalSize,fileName);
    } progressChanged:^(double progress, long long downloadLength) {
        // 更新view
        model.progress = progress;
        cell.model = model;
        
        NSLog(@"正在获取分片:%f",progress);
    } complete:^{
        // 解析所有分片
        [weakSelf getAllFrames:model cell:cell];
        NSLog(@"获取分片完成：%@",model.originalSavePath);
    } faile:^(NSError * _Nonnull error) {
        model.status = downloadStatusError;
        cell.model = model;
        
        // 当前任务下载失败 开启下一个任务下载
        [weakSelf downloadNextFile:model];
    }];
}

/**
 * 从下载的源m3u8文件中h解析所有的m3u8视频分片
 */
- (void)getAllFrames:(HYM3u8FileModel *)model cell:(HYM3u8DownloadCell *)cell
{
    // 把下载的源m3u8文件转换成字符串
    NSString *content = [NSString stringWithContentsOfFile:model.originalSavePath encoding:NSUTF8StringEncoding error:nil];
    
    // 以换行符为分隔符 分割字符串
    NSArray *contentArray = [content componentsSeparatedByString:@"\n"];
    
    // 遍历数组 筛选出后缀是.ts的文件
    NSMutableArray *tsList = [NSMutableArray array];
    for (NSString *str in contentArray) {
        if ([str containsString:@".ts"]) {
            NSArray *arr = [str componentsSeparatedByString:@"/"];
            if (arr.count > 1) {
                [tsList addObject:arr.lastObject];
            }else {
                [tsList addObject:str];
            }
        }
    }
    model.tsListsArray = tsList;

    cell.model = model;
    
    // 开始下载分片
    [self downloadFrame:model cell:cell];
}

/**
 * 下载分片
 */
- (void)downloadFrame:(HYM3u8FileModel *)model cell:(HYM3u8DownloadCell *)cell
{
    __weak typeof(self) weakSelf = self;
    
    // 修改下载状态
    model.status = downloadStatusDownloadingFrame;
    cell.model = model;
    
    // ts文件的下载路径
    NSString *tsDownloadUrl = [model.downloadUrl stringByReplacingOccurrencesOfString:model.downloadUrl.lastPathComponent withString:model.tsListsArray[model.downloadFrameIndex]];
    
    // ts文件的存储路径
    NSString *savePath = [model.tsSaveDir stringByAppendingPathComponent:model.tsListsArray[model.downloadFrameIndex]];
    
    // 开始下载
    [[HYURLConnectionDownload share] downloadFile:tsDownloadUrl savePath:savePath didReceiveResponse:^(long long totalSize, NSString * _Nonnull fileName) {

    } progressChanged:^(double progress, long long downloadLength) {
        // 更新进度
        model.progress = progress;
        cell.model = model;
    } complete:^{
        // 下载完成 开启下一个ts文件下载
        if (model.downloadFrameIndex < model.tsListsArray.count - 1) {
            model.downloadFrameIndex++;
            cell.model = model;
            
            // 开启下载下一个ts文件
            [weakSelf downloadFrame:model cell:cell];
        }else {
            // 所有分片下载完成 开始合成视频
            model.status = downloadStatusMergeFrames;
            cell.model = model;
            [weakSelf mergeTs:model progressBlock:^(double progress) {
                // 合成进度更新
                model.progress = progress;
                cell.model = model;
                NSLog(@"合成进度:%f",progress);
            } complete:^{
                // 合成完成 利用ffmpeg转换视频格式
                [weakSelf convertFileWithModel:model progressBlock:^(double progress) {
                    model.progress = progress;
                    cell.model = model;
                } completeBlock:^{
                    // 转换完成
                    model.status = downloadStatusComplete;
                    cell.model = model;
                    
                    // 开启下一个下载任务
                    [weakSelf downloadNextFile:model];
                }];
            }];
        }
    } faile:^(NSError * _Nonnull error) {
        model.status = downloadStatusError;
        cell.model = model;
        
        NSLog(@"下载第%d个分片失败,当前url:%@",model.downloadFrameIndex,model.downloadUrl);
        
        // 当前任务部分分片下载失败 开始下一个任务
        [weakSelf downloadNextFile:model];
    }];
}

/**
 * 下载下一个任务
 */
- (void)downloadNextFile:(HYM3u8FileModel *)currentModel
{
    __weak typeof(self) weakSelf = self;
    NSInteger preIndex = [weakSelf.downloadUrlArr indexOfObject:currentModel];
    if (preIndex + 1 < weakSelf.downloadUrlArr.count) {
        // 后面还有任务 开始下载下一个任务
        HYM3u8DownloadCell *nextCell = [weakSelf cellWithRowIndex:preIndex + 1];
        HYM3u8FileModel *nextModel = weakSelf.downloadUrlArr[preIndex + 1];
        [weakSelf scrollToRow:preIndex + 1];
        
        NSLog(@"开始下载任务:%@",nextModel.downloadUrl);
        [weakSelf downloadOriginalU3m8:nextModel cell:nextCell];
    }else {
        // 后面没有任务了
        [HYToast toastWithMessage:@"任务已全部下载完成"];
    }
}

@end
