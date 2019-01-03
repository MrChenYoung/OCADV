//
//  HYURLConnectionController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYURLConnectionController.h"
#import "HYURLConnectionUtil.h"
#import "HYAFNRequestUtil.h"
#import "HYPlayVideoController.h"

@interface HYURLConnectionController ()

@property (nonatomic, strong) HYURLConnectionUtil *urlConnection;
@end

@implementation HYURLConnectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlConnection = [HYURLConnectionUtil share];
    
    [self loadRequests];
}

- (void)loadRequests
{
    __weak typeof(self) weakSelf = self;
    
    // 同步GET请求
    self.syncGetRequestBlock = ^(NSString * _Nonnull phoneNumber) {
        NSDictionary *parameters = @{@"tel":phoneNumber};
        NSData *result = [HYURLConnectionUtil syncGET:checkPhoneNumberUrl headers:nil parameters:parameters];
        NSString *str = [result toString];
        if (str) {
            weakSelf.requestResult = str;
        }else {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }
    };
    
    // 同步PSOT请求
    self.syncPostRequestBlock = ^(NSString * _Nonnull phoneNumber) {
        NSDictionary *parameters = @{@"tel":phoneNumber};
        NSData *result = [HYURLConnectionUtil syncPOST:checkPhoneNumberUrl headers:nil parameters:parameters];
        NSString *str = [result toString];
        if (str) {
            weakSelf.requestResult = str;
        }else {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }
    };
    
    // 异步GET请求
    self.asyncGetRequestBlock = ^(NSString * _Nonnull phoneNumber) {
        [SVProgressHUD show];
        
        NSDictionary *parameters = @{@"tel":phoneNumber};
        [HYURLConnectionUtil GET:checkPhoneNumberUrl headers:nil parameters:parameters complete:^{
            // 去掉loading
            [SVProgressHUD dismiss];
        } success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
            // 显示结果到界面上
            NSString *str = [result toString];
            weakSelf.requestResult = str;
        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }];
        
//        NSString *url = @"http://testapi.babatruck.com/app/account/SignIn";
//        NSDictionary *body = @{@"mobileTel":@"13761943167",
//                               @"passWord":@"123456",
//                               @"type":@"0"};
//        [HYURLConnectionUtil GET:url headers:nil parameters:body complete:^{
//            [SVProgressHUD dismiss];
//        } success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
//            NSString *str = [result toString];
//            NSLog(@"请求成功:%@",str);
//        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
//            NSLog(@"请求失败");
//        }];
    };
    
    // 异步POST请求
    self.asyncPostRequestBlock = ^(NSString * _Nonnull phoneNumber) {
        [SVProgressHUD show];
        
        NSDictionary *parameters = @{@"tel":phoneNumber};
        [HYURLConnectionUtil POST:checkPhoneNumberUrl headers:nil parameters:parameters complete:^{
            [SVProgressHUD dismiss];
        } success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
            // 显示结果到界面上
            NSString *str = [result toString];
            weakSelf.requestResult = str;
        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }];
        
    };
    
    // 开始下载回调
    self.downloadStartBlock = ^(NSString * _Nonnull downloadUrl, NSString * _Nonnull savePath) {
        [weakSelf.urlConnection downloadFile:downloadUrl savePath:[HYMoviesResolver share].netDownloadFileSavePath didReceiveResponse:^(long long totalSize, NSString * _Nonnull fileName) {
            // 开始下载
            weakSelf.downloadState = fileStateDownloading;
            weakSelf.downloadFileName = fileName;
            weakSelf.downloadFileTotalSize = totalSize;
        }progressChanged:^(double progress,long long downloadLength) {
            // 下载进度改变
            weakSelf.downloadProgress = progress;
            weakSelf.downloadFileSaveSize = downloadLength;
        }complete:^{
            // 下载完成
            weakSelf.downloadState = fileStateDownloaded;
        }faile:^(NSError * _Nonnull error) {
            // 下载失败
            weakSelf.downloadState = fileStatePause;
        }];
    };
    
    // 暂停下载回调
    self.downloadPauseBlock = ^(NSString * _Nonnull url) {
        BOOL success = [weakSelf.urlConnection downloadPause:url];
        if (success) {
            weakSelf.downloadState = fileStatePause;
        }else {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"没有找到下载任务" inCtr:weakSelf];
        }
    };
    
    // 继续下载回调
    self.downloadResumeBlock = ^(NSString * _Nonnull url) {
        BOOL success = [weakSelf.urlConnection downloadResume:url];
        if (success) {
            weakSelf.downloadState = fileStateDownloading;
        }else {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"没有找到暂停的下载任务" inCtr:weakSelf];
        }
    };
    
    // 播放回调
    self.playBlock = ^{
        
    };
}

- (void)testRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://tcc.taobao.com/cc/json/mobile_tel_segment.htm"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/javascript" forHTTPHeaderField:@"Content-Type"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"tel":@"13761943167"} options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = jsonData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    } else {
                                                        NSError *err = nil;
                                                        
                                                        NSLog(@"成功:%@",data);
                                                    }
                                                }];
    [dataTask resume];
}

- (void)dealloc
{
    NSLog(@"URLConnection界面销毁");
}

@end
