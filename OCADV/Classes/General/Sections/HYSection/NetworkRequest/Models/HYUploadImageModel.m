//
//  HYUploadImageModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/9.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYUploadImageModel.h"

@interface HYUploadImageModel ()

// 上传的具体时间
@property (nonatomic, copy, readwrite) NSString *uploadDate;

@end

@implementation HYUploadImageModel

@synthesize media_id = _media_id;

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


#pragma mark - setter getter
/**
 * 设置image
 */
- (void)setImage:(UIImage *)image
{
    _image = image;
    
    NSData *data = UIImagePNGRepresentation(image);
    self.imageLengthFormate = [NSByteCountFormatter stringFromByteCount:data.length countStyle:NSByteCountFormatterCountStyleFile];
}

/**
 * 通过图片名字查询是否已经上传
 */
- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    [self reloadImageStatus:nil];
}

/**
 * 设置图片在服务器的标示，标记已经上传
 */
- (void)setMedia_id:(NSString *)media_id
{
    _media_id = media_id;
    
    // 本地保存服务器返回的id
    [[NSUserDefaults standardUserDefaults] setObject:media_id forKey:self.imageName];
    
    // 本地保存上传到服务器的图片
    NSData *imageData = UIImagePNGRepresentation(self.image);
    [[NSUserDefaults standardUserDefaults] setObject:imageData forKey:[self.imageName stringByAppendingString:@"_updateImage"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 获取图片存储在服务器的路径
 */
- (NSString *)media_id
{
    if (_media_id == nil || _media_id.length == 0) {
        NSString *imageId = [[NSUserDefaults standardUserDefaults] stringForKey:self.imageName];
        return imageId ? imageId : @"";
    }else {
        return _media_id;
    }
}

/**
 * 设置上传时间
 */
- (void)setUploadTimestamp:(double)uploadTimestamp
{
    _uploadTimestamp = uploadTimestamp;
   
    // 时间戳转日期
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:uploadTimestamp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [formatter stringFromDate:date];
    self.uploadDate = dateString;
}

#pragma mark - custom
/**
 * 删除本地存储的图片信息
 */
- (void)deleteImageComplete:(void (^)(void))complete success:(void (^)(void))success faile:(void (^)(void))faile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.imageName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self.imageName stringByAppendingString:@"_updateImage"]];
        BOOL result = [[NSUserDefaults standardUserDefaults] synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
            
            if (result) {
                // 删除成功
                if (success) {
                    success();
                }
            }else {
                // 删除失败
                if (faile) {
                    faile();
                }
            }
        });
    });
}

/**
 * 刷新image上传状态
 */
- (void)reloadImageStatus:(void (^)(void))complete
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 从本地查询是否上传过照片
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *imageUrl = [defaults stringForKey:weakSelf.imageName];
        if (imageUrl.length > 0) {
            self.status = uploadStatusLoad;
        }else {
            self.status = uploadStatusUnload;
        }
        
        // 从本地取保存的图片
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:[weakSelf.imageName stringByAppendingString:@"_updateImage"]];
        UIImage *image = [UIImage imageWithData:imageData];
        if (image) {
            self.image = image;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
        });
    });
}

#pragma mark - newRequest


@end
