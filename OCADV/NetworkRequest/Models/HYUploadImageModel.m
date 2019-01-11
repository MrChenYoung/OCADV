//
//  HYUploadImageModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/9.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYUploadImageModel.h"

@implementation HYUploadImageModel

@synthesize remoteUrl = _remoteUrl;

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

/**
 * 通过图片名字查询是否已经上传
 */
- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    // 从本地查询是否上传过照片
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *imageUrl = [defaults stringForKey:imageName];
    if (imageUrl.length > 0) {
        self.status = uploadStatusLoad;
    }else {
        self.status = uploadStatusUnload;
    }
}

- (void)setRemoteUrl:(NSString *)remoteUrl
{
    _remoteUrl = remoteUrl;
    
    [[NSUserDefaults standardUserDefaults] setObject:remoteUrl forKey:self.imageName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 获取图片存储在服务器的路径
- (NSString *)remoteUrl
{
    if (_remoteUrl == nil || _remoteUrl.length == 0) {
        NSString *imageUrl = [[NSUserDefaults standardUserDefaults] stringForKey:self.imageName];
        return imageUrl;
    }else {
        return _remoteUrl;
    }
}

@end
