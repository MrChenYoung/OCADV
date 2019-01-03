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

@end
