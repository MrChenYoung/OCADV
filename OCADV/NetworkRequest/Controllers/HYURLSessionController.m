//
//  HYURLSessionController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYURLSessionController.h"

@interface HYURLSessionController ()

@end

@implementation HYURLSessionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [[HYGeneralSingleTon share] reloadAccessTokenCoreCode:^(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void)) {
//        [HYURLConnectionUtil GET:urlString headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
//            if (success) {
//                success(result);
//            }
//            
//            NSLog(@"获得token:%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
//        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
//            NSLog(@"获取token失败");
//        }];
//    }];
    
//    NSDictionary *parameters = @{@"access_token":[HYGeneralSingleTon share].accessToken};
//    [HYURLConnectionUtil GET:@"https://api.weixin.qq.com/cgi-bin/material/get_materialcount" headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
//        NSLog(@"%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
//    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
//        NSLog(@"请求失败:%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
//    }];
    
    
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token=%@",[HYGeneralSingleTon share].accessToken];
    NSDictionary *parameters = @{@"type":@"image",@"offset":[NSNumber numberWithInt:0],@"count":[NSNumber numberWithInt:10]};
    [HYURLConnectionUtil POST:url headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
        NSLog(@"%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
    } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
        NSLog(@"请求失败:%@",[[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding]);
    }];
}

@end
