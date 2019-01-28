//
//  HYMoviesResolver.m
//  OCADV
//
//  Created by MrChen on 2018/12/27.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYGeneralSingleTon.h"
#import "HYStreamVideoModel.h"

@interface HYGeneralSingleTon()

// 请求微信公众平台接口需要的accessToken
@property (nonatomic, copy, readwrite) NSString *accessToken;

// 在线视频
@property (nonatomic, copy, readwrite) NSArray *onlineVideos;

// 本地视频
@property (nonatomic, strong, readwrite) NSMutableArray *localVideos;

// 直播视频
@property (nonatomic, copy, readwrite) NSArray *streamVideos;

// 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
@property (nonatomic, assign, readwrite) NSTimeInterval m3u8TimeInterval;

@end

@implementation HYGeneralSingleTon
@synthesize accessToken = _accessToken;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYGeneralSingleTon *singleTon;
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

#pragma mark - setter getter
/**
 * 开始创建m3u8文件model时候的时间戳(作为第一个m3u8文件的保存文件夹名,后面文件名字在此基础上累加)
 */
- (NSTimeInterval)m3u8TimeInterval
{
    return [[NSDate date] timeIntervalSince1970];
}

/**
 * 获取accessToken
 */
- (NSString *)accessToken
{
    if (_accessToken == nil) {
        _accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:KACCESSTOKENKEY];
    }
    
    return _accessToken;
}

/**
 * 保存accessToken
 */
- (void)setAccessToken:(NSString *)accessToken
{
    _accessToken = accessToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:KACCESSTOKENKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - custom method

/**
 * 一次性代码
 */
- (void)singleExecuteCode
{
    // 加载要下载的电影
//    [self loadOnlineMovies];
    
    // 创建本地视频数组
    if (self.localVideos == nil) {
        self.localVideos = [NSMutableArray array];
    }
    
    // 初始化上传到服务器的图片列表信息数组
    if (self.imageListArray == nil) {
        self.imageListArray = [NSMutableArray array];
    }
}

/**
 * 获取本地视频(扫描所有的文件夹筛选出视频文件)
 * block 获取到一个视频文件回调一次
 */
- (void)loadLocalVideosBlock:(void (^)(HYNormalVideoModel *model))block
{
    NSString *homePath = NSHomeDirectory();
    [self loadVideosInDirectory:homePath block:block];
}

/**
 * 获取指定文件夹中的视频文件
 * dirPath文件夹绝对路径
 */
- (void)loadVideosInDirectory:(NSString *)dirPath block:(void (^)(HYNormalVideoModel *model))block
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:dirPath error:nil];
        // 遍历所有文件，筛选出视频文件
        for (NSString *filePath in files) {
            BOOL isDir = NO;
            NSString *fullPath = [dirPath stringByAppendingPathComponent:filePath];
            BOOL exist = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];
            
            if (isDir) {
                // 是文件夹 递归
                if (exist) {
                    [self loadVideosInDirectory:fullPath block:block];
                }
            }else {
                // 是文件 判断是不是视频文件
                if (!exist) {
                    NSLog(@"文件不存在");
                }else {
                    [HYAVUtil getFileMimeTypeWithUrl:fullPath complete:^(NSString * _Nonnull mimeType) {
                        if ([[mimeType componentsSeparatedByString:@"/"].firstObject isEqualToString:@"video"]) {
                            // 是视频文件
                            HYNormalVideoModel *videoModel = [[HYNormalVideoModel alloc]init];
                            videoModel.urlString = fullPath;
                            videoModel.title = filePath;
                            [self.localVideos addObject:videoModel];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (block) {
                                    block(videoModel);
                                }
                            });
                        }
                    }];
                }
            }
        }
    });
}

/**
 * 获取在线视频信息
 */
- (void)loadOnlineVideos
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videoData.plist" ofType:nil];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dic in array) {
        HYNormalVideoModel *model = [HYNormalVideoModel videoWithDic:dic];
        [resultArray addObject:model];
    }
    
    self.onlineVideos = [resultArray copy];
}

/**
 * 加载直播回放视频
 */
- (void)loadStreamVideos
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"m3u8Files1" ofType:nil];
    NSString *m3u8Content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *numbers = [m3u8Content componentsSeparatedByString:@"%"];
    NSString *urlStr = numbers.lastObject;

    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 10; i < 11; i++) {
//        NSString *urlString = [NSString stringWithFormat:@"http://www.tszye.cn:2100/%@/500kb/hls/index.m3u8",numbers[i]];
        HYStreamVideoModel *videoModel = [[HYStreamVideoModel alloc]init];
        videoModel.urlString = [urlStr stringByReplacingOccurrencesOfString:@"*" withString:numbers[i]];
        videoModel.title = numbers[i];
        [arrM addObject:videoModel];
    }
    self.streamVideos = [arrM copy];
}

#pragma mark - netRequest
/**
 * accessToken过期以后刷新
 * coreCode 网络请求核心代码
 */
- (void)reloadAccessTokenCoreCode:(void (^)(NSString *urlString, NSDictionary *parameters,void (^success)(NSData *response),void (^faile)(void)))coreCode
{
    NSDictionary *params = @{@"grant_type":@"client_credential",@"appid":AppId,@"secret":AppSecret};
    
    // 获取token成功
    void (^requestSuccess)(NSData *response) = ^(NSData *response){
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
        NSString *accessToken = dic[@"access_token"];
        if (accessToken) {
            self.accessToken = accessToken;
        }
    };
    
    // 获取token失败
    void (^requestFaile)(void) = ^{
        [HYToast toastWithMessage:@"登录失败"];
    };
    
    if (coreCode) {
        coreCode(GetAccessTokenUrl,params,requestSuccess,requestFaile);
    }
}

@end
