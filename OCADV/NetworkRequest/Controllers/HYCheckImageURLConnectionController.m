//
//  HYPlayVideoController.m
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYCheckImageURLConnectionController.h"

@interface HYCheckImageURLConnectionController ()



@end

@implementation HYCheckImageURLConnectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLoadImageBlock];
}

/**
 * 绑定block
 */
- (void)setLoadImageBlock
{
    __weak typeof(self) weakSelf = self;
    // 获取tokenblock
    self.requestAccessTokenBlock = ^(NSString * _Nonnull urlString, NSDictionary * _Nonnull parameters, void (^ _Nonnull success)(NSData * _Nonnull), void (^ _Nonnull faile)(void)) {
        [weakSelf requestAccessToken:urlString parameters:parameters success:success faile:faile];
    };
    
    // 获取图片信息
    self.loadImageBlock = ^(NSString * _Nonnull urlString, void (^ _Nonnull success)(NSData * _Nonnull), void (^ _Nonnull faile)(void)) {
        [weakSelf requestImage:urlString success:success faile:faile];
    };
    
    // 删除图片信息回调
    self.deleteImageBlock = ^(NSString * _Nonnull urlString, NSDictionary * _Nonnull parameters, void (^ _Nonnull success)(NSData * _Nonnull), void (^ _Nonnull faile)(void)) {
        [weakSelf deleteImage:urlString parameters:parameters success:success faile:faile];
    };
}

/**
 * 获取图片信息
 */
- (void)requestImage:(NSString *)url success:(void (^)(NSData *response))success faile:(void (^)(void))faile
{
    [HYURLConnectionUtil GET:url headers:nil parameters:nil complete:^{
        
    } success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
        if (success) {
            success(result);
        }
    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
        if (faile) {
            faile();
        }
    }];
}

/**
 * 删除图片
 */
- (void)deleteImage:(NSString *)urlString parameters:(NSDictionary *)parameters success:(void (^)(NSData *response))success faile:(void (^)(void))faile
{
    [HYURLConnectionUtil POST:urlString headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
        if (success) {
            success(result);
        }
    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
        if (faile) {
            faile();
        }
    }];
}

/**
 * 获取token
 */
- (void)requestAccessToken:(NSString *)url parameters:(NSDictionary *)parameters success:(void (^)(NSData *result))requestSuccess faile:(void (^)(void))faile
{
    [HYURLConnectionUtil GET:url headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
        if (requestSuccess) {
            requestSuccess(result);
        }
    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
        if (faile) {
            faile();
        }
    }];
}



@end
