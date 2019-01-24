//
//  HYPhotoAlbumManager.m
//  XRWaterfallLayoutDemo
//
//  Created by MrChen on 2018/3/22.
//  Copyright © 2018年 MrChen. All rights reserved.
//

#import "HYPhotoAlbumManager.h"

#define SystemVersion [[UIDevice currentDevice] systemVersion].floatValue

@interface HYPhotoAlbumManager ()

// 相册数据库
@property (nonatomic, strong) ALAssetsLibrary *assetslibrary;

@end

@implementation HYPhotoAlbumManager

#pragma mark - 懒加载
// 相册数据库
- (ALAssetsLibrary *)assetslibrary
{
    if (_assetslibrary == nil) {
        _assetslibrary = [[ALAssetsLibrary alloc]init];
    }
    
    return _assetslibrary;
}

#pragma mark - 单利方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYPhotoAlbumManager *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [super allocWithZone:zone];
    });
    
    return mgr;
}

// 获取单利
+ (instancetype)shareManager
{
    return [[self alloc]init];
}


#pragma mark - AssetsLibrary库
/**
 * get photos(异步获取)
 * assert 每次遍历获取的单张照片对象(直接转换成UIImage对象速度太慢,所以返回ALAsset对象,每次给UIImageView设置image的时候再转换)
 */
- (void)getAllPhotosBlock:(void (^)(ALAsset *assert))stepPhotoBlock
{
    // 遍历相册库里的相册
    [self.assetslibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // 相册封面
//        CGImageRef cgImage = [group posterImage];
//        UIImage *coverImage = [UIImage imageWithCGImage:cgImage];
        
//        NSString *groupname = [group valueForProperty:ALAssetsGroupPropertyName];
//        NSLog(@"相册名字:%@, %ld",groupname,(long)[group numberOfAssets]);
        
        // 遍历相册
        if (group != nil) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                NSString *type = [result valueForProperty:ALAssetPropertyType];

                if ([type isEqualToString:ALAssetTypePhoto]) {
                    // 照片
                    if (stepPhotoBlock) {
                        stepPhotoBlock(result);
                    }
                }else if ([type isEqualToString:ALAssetTypeVideo]) {
                    // 视频,写入document文件夹
//                    ALAssetRepresentation *representation = [result defaultRepresentation];
//                    [self videoWithUrl:representation.url withFileName:representation.filename];
                }else if ([type isEqualToString:ALAssetTypeUnknown]) {
                    // 未知
                    NSLog(@"------------");
                }
                
            }];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"遍历错误");
    }];
}

/**
 * 根据照片对象获取缩略图(太模糊,不建议使用)
 * assert 照片对象
 */
- (UIImage *)thumbnailWithAssert:(ALAsset *)assert
{
    // 缩略图
    CGImageRef imageRef = [assert thumbnail];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
    return image;
}


/**
 * 根据照片对象获取大尺寸图片(系统相册使用,建议使用)
 * assert 照片对象
 */
- (UIImage *)fullScreenImageWithAssert:(ALAsset *)assert
{
    // fullScreenImage
    ALAssetRepresentation *rap = [assert defaultRepresentation];
    CGImageRef fullImageRef = [rap fullScreenImage];
    UIImage *fullScrImg = [UIImage imageWithCGImage:fullImageRef];
    
    return fullScrImg;
}

/**
 * 根据照片对象获取超大尺寸图片(太大,不建议使用)
 * assert 照片对象
 */
- (UIImage *)fullResolutionImageWithAssert:(ALAsset *)assert
{
    // fullResolutionImg
    ALAssetRepresentation *rap = [assert defaultRepresentation];
    CGImageRef fullResolutionRef = [rap fullResolutionImage];
    UIImage *fullResolutionImg = [UIImage imageWithCGImage:fullResolutionRef];
    
    return fullResolutionImg;
}

/**
 * 根据照片对象获取图片名字
 * assert 照片对象
 */
- (NSString *)imageNameWithAssert:(ALAsset *)assert
{
    return [[assert defaultRepresentation] filename];
}

// 将原始视频的URL转化为NSData数据,写入沙盒
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
                NSString * videoPath = [documentPath stringByAppendingPathComponent:fileName];
                char const *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 1024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                }
            } failureBlock:nil];
        }
    });
}

#pragma mark - Photos库
/**
 * 获取所有照片(因为请求用户授权是异步的，所以用回调的方式)
 * complete 完成回调
 */
- (void)getAllPhototsComplete:(void (^)(NSArray <PHAsset *>*result))complete
{
    // 首线请求授权使用相册
    PHAuthorizationStatus statue = [PHPhotoLibrary authorizationStatus];
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        // 请求授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    // 用户同意使用相册
                    NSArray *arr = [self photos];
                    if (complete) {
                        complete(arr);
                    }
                }else {
                    // 用户拒绝使用相册
                    [self showAlert:@"用户拒绝使用相册"];
                }
            });
            
        }];
    }else if (statue == PHAuthorizationStatusDenied) {
        // 用户拒绝使用相册
        [self showAlert:@"用户拒绝使用相册"];
    }else if (statue == PHAuthorizationStatusAuthorized) {
        // 用户已经授权过
        if (complete) {
            complete([self photos]);
        }
    }
}

// 授权以后获取照片
- (NSArray *)photos
{
    NSMutableArray <PHAsset *>*photos = [NSMutableArray array];
    
    // 获取所有相簿
    NSArray <PHAssetCollection *>*albums = [self getAllPhotoAlbum];
    
    // 遍历相簿获取照片
    for (PHAssetCollection *collection in albums) {
        NSLog(@"相册:%@",[self transformAblumTitle:collection.localizedTitle]);
        NSArray *arr = [self enumerateAssetsInAssetCollection:collection];
        [photos addObjectsFromArray:arr];
    }
    
    return [photos mutableCopy];
}

- (NSString *)transformAblumTitle:(NSString *)title
{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"Bursts"]) {
        return @"爆发";
    }else if ([title isEqualToString:@"Panoramas"]) {
        return @"全景";
    }else if ([title isEqualToString:@"Hidden"]) {
        return @"隐藏";
    }else if ([title isEqualToString:@"Time-lapse"]) {
        return @"定时";
    }
    return title;
}

/**
 * 获取所有的相簿
 * @return 相簿集合(PHAssetCollection对象集合)
 */
- (NSArray <PHAssetCollection *>*)getAllPhotoAlbum
{
    // 所有的相簿(自定义相簿 + 相机胶卷)
    NSMutableArray *collections = [NSMutableArray array];
    
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 遍历所有的自定义相簿
    [assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            // 过滤相册
            if (fetchResult.count > 0&&collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos && collection.assetCollectionSubtype !=PHAssetCollectionSubtypeSmartAlbumTimelapses) {
                [collections addObject:collection];
            }
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }

    }];
    
    // 获得相机胶卷
    PHFetchResult<PHAssetCollection *> *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [cameraRoll enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            if (fetchResult.count > 0) {
                [collections addObject:collection];
            }
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }];
    
    return collections;
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @return 照片对象
 */
- (NSArray <PHAsset *>*)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection
{
    NSMutableArray *photos = [NSMutableArray array];
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        [photos addObject:asset];
    }
    
    return photos;
}

/**
 * 根据照片对象获取图片名字
 * phAssert 照片对象
 */
- (NSString *)imageNameWithPHAssert:(PHAsset *)phAssert
{
    return [phAssert valueForKey:@"filename"];
}

/**
 * 获取照片(缩略图/原图)
 * assert 照片对象
 * synchronous 是否是同步请求
 * original 是否是原图
 * complete 获取照片后回调(异步获取使用)
 * return 获取的照片(异步获取的时候返回nil)
 */
- (UIImage *)imageWithAssert:(PHAsset *)assert synchronous:(BOOL)synchronous original:(BOOL)original complete:(void (^)(UIImage *image))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 是否同步获得图片, 只会返回1张图片
    options.synchronous = synchronous;
    
    // 是否要原图
    CGSize size = original ? CGSizeMake(assert.pixelWidth, assert.pixelHeight) : CGSizeZero;

    __block UIImage *image = nil;
    
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:assert targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        image = result;
        
        if (!synchronous) {
            if (complete) {
                complete(result);
            }
        }
    }];

    return image;
}


#pragma mark - public
// alert
- (void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}


@end
