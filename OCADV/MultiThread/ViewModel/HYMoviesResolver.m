//
//  HYMoviesResolver.m
//  OCADV
//
//  Created by MrChen on 2018/12/27.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYMoviesResolver.h"

@interface HYMoviesResolver()

// 所有要下载的电影信息
@property (nonatomic, copy, readwrite) NSArray *movies;

// 网络请求篇下载文件的存储路径
@property (nonatomic, copy, readwrite) NSString *netDownloadFileSavePath;

// 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
@property (nonatomic, assign, readwrite) NSTimeInterval m3u8TimeInterval;

@end

@implementation HYMoviesResolver

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYMoviesResolver *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super allocWithZone:zone];
        [singleTon singleExecuteCode];
    });
    
    return singleTon;
}

+ (instancetype)share
{
    return [[self alloc]init];
}

/**
 * 一次性代码
 */
- (void)singleExecuteCode
{
    // 设置网络篇下载文件的保存路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"偶遇野猫.mp4"];
    self.netDownloadFileSavePath = path;
    
    // 加载要下载的电影
    [self loadMovies];
}

/**
 * 加载电影信息 只在单利创建的时候加载一次
 */
- (void)loadMovies
{
    NSLog(@"加载电影信息");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"testData.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        HYDownloadFileModel *model = [HYDownloadFileModel downloadFileWithDic:dic];
        [resultArray addObject:model];
    }

    self.movies = [resultArray copy];
}

#pragma mark - getter
/**
 * 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
 */
- (NSTimeInterval)m3u8TimeInterval
{
    return [[NSDate date] timeIntervalSince1970];
}

@end
