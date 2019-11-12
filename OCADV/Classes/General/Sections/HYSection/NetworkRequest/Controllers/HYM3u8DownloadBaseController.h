//
//  HYM3u8DownloadBaseController.h
//  OCADV
//
//  Created by MrChen on 2019/1/10.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYM3u8DownloadCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HYM3u8DownloadBaseController : UIViewController

// 下载文件列表
@property (nonatomic, strong, readonly) NSArray *downloadUrlArr;

// 开始下载回调
@property (nonatomic, copy) void (^startDownloadBlock)(HYM3u8FileModel *model,HYM3u8DownloadCell *cell);

/**
 * 把所有的ts分片合成一个最终的ts文件
 */
- (void)mergeTs:(HYM3u8FileModel *)model progressBlock:(void (^)(double progress))progressBlock complete:(void (^)(void))complete;

/**
 * 转换合成以后的ts文件
 */
- (void)convertFileWithModel:(HYM3u8FileModel *)model progressBlock:(void (^)(double progress))progressBlock completeBlock:(void (^)(void))completeBlock;

/**
 * 滚动到当前下载的行
 */
- (void)scrollToRow:(NSInteger)rowIndex;

/**
 * 获取指定行的cell
 */
- (HYM3u8DownloadCell *)cellWithRowIndex:(NSInteger)rowIndex;

@end

NS_ASSUME_NONNULL_END
