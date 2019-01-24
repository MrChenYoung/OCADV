//
//  HYURLConnectionController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYURLConnectionController.h"
#import "HYURLConnectionDownload.h"
#import "HYURLConnectionUpload.h"
#import "HYAFNRequestUtil.h"
#import "HYCheckImageURLConnectionController.h"
#import <AFNetworking.h>

@interface HYURLConnectionController ()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, strong) HYURLConnectionDownload *urlConnection;
@end

@implementation HYURLConnectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.urlConnection = [HYURLConnectionDownload share];
    
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
            [weakSelf phoneNumberLocationAnalysis:str];
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
            [weakSelf phoneNumberLocationAnalysis:str];
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
            [weakSelf phoneNumberLocationAnalysis:str];
        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }];
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
            [weakSelf phoneNumberLocationAnalysis:str];
        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
            [HYToast toastWithMessage:@"网络错误,请检查网络是否正常连接."];
        }];
    };
    
    // 开始下载回调
    self.downloadStartBlock = ^(HYDownloadFileModel * _Nonnull model) {
        [weakSelf.urlConnection downloadFile:model.downloadUrl savePath:model.savePath didReceiveResponse:^(long long totalSize, NSString * _Nonnull fileName) {
            // 开始下载
            model.downloadStatus = fileDownloadStatusDownloading;
            model.remoteName = fileName;
            model.totalLength = totalSize;
            weakSelf.downloadFileModel = model;
        }progressChanged:^(double progress,long long downloadLength) {
            // 下载进度改变
            model.downloadProgress = progress;
            model.downloadLength = downloadLength;
            weakSelf.downloadFileModel = model;
        }complete:^{
            // 下载完成
            model.downloadStatus = fileDownloadStatusDownloaded;
            weakSelf.downloadFileModel = model;
        }faile:^(NSError * _Nonnull error) {
            // 下载失败
            model.downloadStatus = fileDownloadStatusPause;
            weakSelf.downloadFileModel = model;
        }];
    };
    
    // 暂停下载回调
    self.downloadPauseBlock = ^(HYDownloadFileModel * _Nonnull model) {
        BOOL success = [weakSelf.urlConnection downloadPause:model.downloadUrl];
        if (success) {
            model.downloadStatus = fileDownloadStatusPause;
            weakSelf.downloadFileModel = model;
        }else {
            [HYAlertUtil showAlertTitle:@"提示" msg:@"没有找到下载任务" inCtr:weakSelf];
        }
    };
    
    // 继续下载回调
    self.downloadResumeBlock = ^(HYDownloadFileModel * _Nonnull model) {
        BOOL success = [weakSelf.urlConnection downloadResume:model.downloadUrl];
        if (success) {
            model.downloadStatus = fileDownloadStatusDownloading;
            weakSelf.downloadFileModel = model;
        }else {
            if (weakSelf.downloadStartBlock) {
                weakSelf.downloadStartBlock(model);
            }
        }
    };
    
    // 上传照片回调
    
    // 获取token回调
    self.requestAccessTokenBlock = ^(NSString * _Nonnull urlString, NSDictionary * _Nonnull parameters, void (^ _Nonnull success)(NSData * _Nonnull), void (^ _Nonnull faile)(void)) {
        [weakSelf requestAccessToken:urlString parameters:parameters success:success faile:faile];
    };
    
    // 上传图片回调
    self.uploadImageBlock = ^(NSString * _Nonnull urlString, NSDictionary * _Nonnull parameters, NSData * _Nonnull imageData, void (^ _Nonnull success)(NSString * _Nonnull), void (^ _Nonnull faile)(void), void (^ _Nonnull progress)(double), void (^ _Nonnull finish)(NSString * _Nonnull)) {
        [weakSelf uploadImage:urlString parameters:parameters imageData:imageData success:success faile:faile progressBlock:progress finish:finish];
    };
    
    // 获取图片列表回调
    self.loadImageListBlock = ^(NSString * _Nonnull urlString, NSDictionary * _Nonnull parameters, void (^ _Nonnull requestSuccess)(NSData * _Nonnull)) {
        [HYURLConnectionUtil POST:urlString headers:nil parameters:parameters complete:nil success:^(NSData * _Nonnull result, NSURLResponse * _Nonnull response) {
            if (requestSuccess) {
                requestSuccess(result);
            }
        } faile:^(NSURLResponse * _Nonnull response, NSData * _Nonnull result, NSError * _Nonnull error) {
            NSLog(@"从服务器获取图片列表失败");
        }];
    };
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

/**
 * 上传图片
 */
- (void)uploadImage:(NSString *)urlString parameters:(NSDictionary *)parameters imageData:(NSData *)imageData success:(void (^)(NSString *result))success faile:(void (^)(void))faile progressBlock:(void (^)(double progress))progressBlock finish:(void (^)(NSString *responseStr))finish
{
    [[HYURLConnectionUpload share] uploadFile:urlString paramName:@"media" fileName:self.uploadImageModel.imageName contentType:@"image/*" header:nil params:parameters fileData:imageData success:^(NSString *response) {
        // 上传成功
        if (success) {
            success(response);
        }
    } faile:^(NSError *error, NSString *errorMessage) {
        // 上传失败
        if (faile) {
            faile();
        }
    } progress:^(CGFloat progress) {
        // 上传进度改变
        if (progressBlock) {
            progressBlock(progress);
        }
    } finish:^(NSString *responseContent){
        // 上传完成
        if (finish) {
            finish(responseContent);
        }
    }];
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
