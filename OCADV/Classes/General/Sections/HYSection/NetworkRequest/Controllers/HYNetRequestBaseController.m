//
//  HYNetRequestBaseController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYNetRequestBaseController.h"
#import "HYDownloadFileModel.h"
#import "HYCheckImageURLConnectionController.h"
#import "HYUploadView.h"
#import "HYM3u8VedioDownloadController.h"
#import "HYPresentViewController.h"
#import "HYPlayDownloadVideoController.h"

@interface HYNetRequestBaseController ()

// scrollView
@property (nonatomic, weak) UIScrollView *scrollView;

// 电话号码输入框
@property (nonatomic, weak) UITextField *phoneNumberF;

// 结果显示框
@property (nonatomic, weak) UITextView *resultTextView;

// 下载视图
@property (nonatomic, weak) HYDownloadView *downloadView;

// m3u8下载视图
@property (nonatomic, weak) HYButton *m3u8DownloadBtn;

// 上传图片标题label
@property (nonatomic, weak) UILabel *uploadImageTitleLabel;

// 当前view添加上毛玻璃效果后的截图(视频下载完以后点击播放动画用)
@property (nonatomic, strong) UIImage *screenShotImage;

// 上传文件视图
@property (nonatomic, strong) HYUploadView *uploadView;

@end

@implementation HYNetRequestBaseController
@synthesize downloadFileModel = _downloadFileModel;
@synthesize uploadImageModel = _uploadImageModel;

#pragma mark - original method
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建子视图
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 刷新下载文件的状态
    [self reloadDownloadFileStatus];
    
    // 注册相册照片加载完成通知 刷新上传image状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUploadImagesStatus) name:KLOADIMAGECOMPLETE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 注销注册的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KLOADIMAGECOMPLETE object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)dealloc
{
    // 销毁计时器 否侧影响持有计时器的对象销毁
    [self.uploadView destroyTimer];
}

#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubviews
{
    // scrollView
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scroll];
    self.scrollView = scroll;
    
    CGFloat padding = 10.0;
    // 基本POST/GET请求label
    UILabel *baseUseLAbel = [self createModuleTitleLabelOrigin:CGPointMake(padding, padding) text:@"基本POST/GET请求(手机归属地查询)"];
    [scroll addSubview:baseUseLAbel];
    
    // 电话号码输入框
    UITextField *phoneTextF = [[UITextField alloc]initWithFrame:CGRectMake(padding, CGRectGetMaxY(baseUseLAbel.frame) + padding * 0.5, ScWidth - padding * 2.0, 30)];
    phoneTextF.layer.cornerRadius = 3;
    phoneTextF.layer.borderWidth = 0.5;
    phoneTextF.layer.borderColor = ColorLightGray.CGColor;
    phoneTextF.placeholder = @"请输入要查询的电话号码";
    phoneTextF.font = [UIFont systemFontOfSize:14.0];
    phoneTextF.keyboardType = UIKeyboardTypePhonePad;
    phoneTextF.text = @"13761943167";
    [scroll addSubview:phoneTextF];
    self.phoneNumberF = phoneTextF;
    
    // 按钮
    CGFloat lastMaxY = 0;
    NSArray *btnTitles = @[@"同步GET请求",@"同步POST请求",@"异步GET请求",@"异步POST请求"];
    for (int i = 0; i < btnTitles.count; i++) {
        HYButton *btn = [[HYButton alloc]init];
        btn.btnY = CGRectGetMaxY(phoneTextF.frame) + padding + (CGRectGetHeight(btn.frame) + padding * 0.5) * i;
        btn.titleText = btnTitles[i];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        [scroll addSubview:btn];
        lastMaxY = CGRectGetMaxY(btn.frame);
    }
    
    // 请求结果
    UITextView *resultTextView = [[UITextView alloc]initWithFrame:CGRectMake(padding, lastMaxY + padding, ScWidth - padding * 2.0, 120.0)];
    resultTextView.editable = NO;
    resultTextView.placeholder = @"查询结果";
    resultTextView.layer.cornerRadius = 3.0;
    resultTextView.layer.borderWidth = 0.5;
    resultTextView.layer.borderColor = ColorLightGray.CGColor;
    [scroll addSubview:resultTextView];
    self.resultTextView = resultTextView;
    
    // 网络视频下载label
    CGPoint downloadVedioLabelOrigin = CGPointMake(padding, CGRectGetMaxY(resultTextView.frame) + padding);
    UILabel *downloadVedioLabel = [self createModuleTitleLabelOrigin:downloadVedioLabelOrigin text:@"网络视频下载"];
    [scroll addSubview:downloadVedioLabel];
    
    // 下载视图
    __weak typeof(self) weakSelf = self;
    HYDownloadView *downloadView = [[HYDownloadView alloc]initWithFrame:CGRectMake(padding, CGRectGetMaxY(downloadVedioLabel.frame) + padding * 0.5, ScWidth - padding * 2.0, 100.0)];
    [scroll addSubview:downloadView];
    self.downloadView = downloadView;
    // 设置下载数据模型
    HYDownloadFileModel *downloadModel = nil;//[HYGeneralSingleTon share].movies.lastObject;
    downloadView.model = downloadModel;
    // 开始下载回调
    downloadView.downloadStartBlock = ^{
        if (weakSelf.downloadStartBlock) {
            weakSelf.downloadStartBlock(downloadModel);
        }
    };
    // 暂停下载回调
    downloadView.downloadPauseBlock = ^{
        if (weakSelf.downloadPauseBlock) {
            weakSelf.downloadPauseBlock(downloadModel);
        }
    };
    // 继续下载回调
    downloadView.downloadResumeBlock = ^{
        if (weakSelf.downloadResumeBlock) {
            weakSelf.downloadResumeBlock(downloadModel);
        }
    };
    // 播放回调
    downloadView.playBlock = ^{
        // 动画弹出播放视频界面
        [self presentPlayController:nil imageModel:nil playVedio:YES];
        
        // 其他额外需求
        if (weakSelf.playBlock) {
            weakSelf.playBlock();
        }
    };
    
    // m3u8视频下载
    HYButton *m3u8Btn = [[HYButton alloc]init];
    m3u8Btn.titleText = @"m3u8视频下载";
    [m3u8Btn addTarget:self action:@selector(toM3u8Controller) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:m3u8Btn];
    self.m3u8DownloadBtn = m3u8Btn;
    
    // 图片上传
    CGPoint imageUploadLabelOrigin = CGPointMake(padding, CGRectGetMaxY(m3u8Btn.frame) + padding);
    UILabel *imageUploadLabel = [self createModuleTitleLabelOrigin:imageUploadLabelOrigin text:@"图片上传"];
    [scroll addSubview:imageUploadLabel];
    self.uploadImageTitleLabel = imageUploadLabel;
    
    // 创建上传文件视图
    self.uploadView = [[HYUploadView alloc]initWithY:CGRectGetMaxY(imageUploadLabel.frame) + padding * 0.5];
    self.uploadView.uploadImageBlock = ^(HYUploadImageModel * _Nonnull imageModel) {
        weakSelf.uploadImageModel = imageModel;
        
        // 上传图片
        [weakSelf uploadImageToServerSuccess:^{
            
        }];
    };
    self.uploadView.checkUploadedImage = ^(HYUploadImageModel * _Nonnull imageModel, UIImageView * _Nonnull imageView) {
        // 显示查看图片控制器
        weakSelf.uploadImageModel = imageModel;
        [weakSelf presentPlayController:imageView imageModel:imageModel playVedio:NO];
    };

    [scroll addSubview:self.uploadView];

    // 更新frame
    [self updateSubViewFrames];
}

/**
 * 更新subviews frame
 */
- (void)updateSubViewFrames
{
    CGFloat padding = 10.0;
    
    // m3u8下载按钮
    self.m3u8DownloadBtn.btnY = CGRectGetMaxY(self.downloadView.frame) + padding;
    
    // 上传图片标题frame
    CGRect frame = self.uploadImageTitleLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.m3u8DownloadBtn.frame) + padding;
    self.uploadImageTitleLabel.frame = frame;
    
    // 上传图片视图
    CGRect uploadFrame = self.uploadView.frame;
    uploadFrame.origin.y = CGRectGetMaxY(self.uploadImageTitleLabel.frame) + padding * 0.5;
    self.uploadView.frame = uploadFrame;
    
    // scrollview contentSize
    self.scrollView.contentSize = CGSizeMake(ScWidth, CGRectGetMaxY(self.uploadView.frame) + 10.0);
}

/**
 * 创建模块标题label
 */
- (UILabel *)createModuleTitleLabelOrigin:(CGPoint)origin text:(NSString *)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(origin.x, origin.y, self.view.bounds.size.width - 5.0, 30.0)];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.text = text;
    return label;
}

/**
 * 显示播放视频/查看图片控制器
 */
- (void)presentPlayController:(UIImageView *)originImageView imageModel:(HYUploadImageModel *)imageModel playVedio:(BOOL)playVedio
{
    __weak typeof(self) weakSelf = self;
    // 第一步动画 抛物线动画移动
    CGFloat radius = 30.0;
    [weakSelf showPlayViewAnimationViewRadius:radius playVedio:playVedio originImageView:originImageView completion:^{
        // 第一步动画完成,开始第二步扩散圆形展示动画(使用自定义present controller转场动画做)
        HYPresentViewController *presentCtr = nil;
        if (playVedio) {
            // 查看视频
            presentCtr = [[HYPlayDownloadVideoController alloc]init];
            [(HYPlayDownloadVideoController *)presentCtr setDownloadMovieModel:weakSelf.downloadFileModel];
        }else {
            // 查看图片
            presentCtr = [[HYCheckImageURLConnectionController alloc]init];
            [(HYCheckImageBaseCtr *)presentCtr setImageModel:imageModel];
        }
        
        
        // 播放视频界面消失以后动画
        presentCtr.dismissComplete = ^(BOOL deleteVideo) {
            if (deleteVideo) {
                if (playVedio) {
                    // 删除视频
                    [weakSelf.downloadFileModel reloadDownloadStatus];
                    weakSelf.downloadFileModel = weakSelf.downloadFileModel;
                }else {
                    // 删除图片
                    [weakSelf.uploadImageModel reloadImageStatus:^{
                        weakSelf.uploadImageModel = weakSelf.uploadImageModel;
                    }];
                }
                
                [weakSelf hiddenPlayViewAnimationViewRadius:radius playVedio:playVedio originImageView:originImageView delete:YES];
            }else {
                // 关闭查看视频/图片页面
                [weakSelf hiddenPlayViewAnimationViewRadius:radius playVedio:playVedio originImageView:originImageView delete:NO];
            }
        };
        
        presentCtr.fromReact = CGRectMake(weakSelf.view.center.x - radius, weakSelf.view.center.y - radius, radius * 2.0, radius * 2.0);
        presentCtr.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
        [weakSelf presentViewController:presentCtr animated:YES completion:nil];
    }];
}

/**
 * 手机号归属地请求结果处理
 */
- (void)phoneNumberLocationAnalysis:(NSString *)result
{
    // 去掉字符串中多余的字符
    NSString *validResult = [result substringFromIndex:[result rangeOfString:@"{"].location + 1];
    validResult = [validResult stringByReplacingOccurrencesOfString:@"'" withString:@""];
    validResult = [validResult stringByReplacingOccurrencesOfString:@"}" withString:@""];
    validResult = [validResult stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    validResult = [validResult stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // 去掉所有的空格
    validResult = [validResult stringByReplacingOccurrencesOfString:@" " withString:@""];
    validResult = [validResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 解析手机号归属地
    NSString *phoneNumber = nil;
    NSString *localAddress = nil;
    NSString *operator = nil;
    NSString *homeLocation = nil;
    NSArray *strList = [validResult componentsSeparatedByString:@","];
    for (NSString *str in strList) {
        NSArray *subArr = [str componentsSeparatedByString:@":"];
        NSString *firstStr = subArr.firstObject;
        for (int i = 0; i < firstStr.length; i++) {
            NSString *singleStr = [firstStr substringWithRange:NSMakeRange(i, 1)];
            if ([singleStr characterAtIndex:0] == 9) {
                firstStr = [firstStr stringByReplacingOccurrencesOfString:singleStr withString:@""];
            }
        }
        
        NSString *value = subArr.count == 2 ? subArr.lastObject : nil;
        if ([firstStr isEqualToString:@"telString"]) {
            // 手机号
            phoneNumber = value;
        }else if ([firstStr isEqualToString:@"province"]){
            // 所在省份
            localAddress = value;
        }else if ([firstStr isEqualToString:@"catName"]){
            // 运营商
            operator = value;
        }else if ([firstStr isEqualToString:@"carrier"]){
            // 归属地
            homeLocation = value;
        }
    }
    
    // 更新界面
    NSString *results = [@"手机号码:" stringByAppendingString:[NSString stringWithFormat:@"%@\n",phoneNumber]];
    results = [results stringByAppendingString:[NSString stringWithFormat:@"所在地:%@\n",localAddress]];
    results = [results stringByAppendingString:[NSString stringWithFormat:@"运营商:%@\n",operator]];
    results = [results stringByAppendingString:[NSString stringWithFormat:@"归属地:%@",homeLocation]];
    self.resultTextView.text = results;
}

/**
 * 压缩要上传的图片 压缩到500kb
 */
- (void)compressImageComplete:(void (^)(void))complete
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [weakSelf.uploadImageModel.image compressToLength:500 * 1024 ];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.uploadImageModel.image = image;
            weakSelf.uploadImageModel = weakSelf.uploadImageModel;
            
            if (complete) {
                complete();
            }
        });
    });
}

/**
 * 刷新下载文件的状态
 */
- (void)reloadDownloadFileStatus
{
    // 通过读取本地下载的文件的大小更新下载界面
    HYDownloadFileModel *downloadModel = self.downloadView.model;
    [downloadModel reloadDownloadStatus];
    
    // 通知model 刷新界面
    self.downloadView.model = downloadModel;
}

/**
 * 刷新上传image的状态
 */
- (void)reloadUploadImagesStatus
{
    // 加载图片列表刷新图片列表界面
    __weak typeof(self) weakSelf = self;
    [self loadImageListFromServer:^{
        // 加载完成
        NSArray *imageViews = weakSelf.uploadView.imageViewListArray;
        for (HYUploadImageView *imageView in imageViews) {
            HYUploadImageModel *model = imageView.model;
            BOOL upload = NO;
            for (HYServerImageModel *serverModel in [HYGeneralSingleTon share].imageListArray) {
                
                // 如果名字一样说明已经上传过
                if ([serverModel.name isEqualToString:model.imageName]) {
                    upload = YES;
                    
                    if (model.media_id.length > 0) {
                        // 如果media_id相同 没有上传过
                        if ([serverModel.media_id isEqualToString:model.media_id]) {
                            upload = YES;
                            
                            model.url = serverModel.url;
                            model.uploadTimestamp = serverModel.update_time;
                            break;
                            
                           
                        }else {
                            upload = NO;
                        }
                    }else {
                        // 本地没有保存media_id 有可能是客户端被卸载过 按照上传过处理
                        model.media_id = serverModel.media_id;
                        model.uploadTimestamp = serverModel.update_time;
                    }
                    
                    if (upload) {
                        model.url = serverModel.url;
                        model.uploadTimestamp = serverModel.update_time;
                    }
                }
            }
            
            if (upload) {
                model.status = uploadStatusLoad;
            }else {
                model.status = uploadStatusUnload;
            }
            imageView.model = model;
        }
        
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - lazy loading
/**
 * 当前view添加上毛玻璃效果后的截图(视频下载完以后点击播放动画用)
 */
- (UIImage *)screenShotImage
{
    if (_screenShotImage == nil) {
        UIView *blurView = [self.view blurEffectView];
        [self.view addSubview:blurView];
        
        // 截图
        _screenShotImage = [self.view toImage];
        
        // 去掉添加的毛玻璃视图
        [blurView removeFromSuperview];
    }
    
    return _screenShotImage;
}

#pragma mark - setter getter
/**
 * 获取下载文件的model
 */
- (HYDownloadFileModel *)downloadFileModel
{
    return self.downloadView.model;
}

/**
 * 设置下载文件的model
 */
- (void)setDownloadFileModel:(HYDownloadFileModel *)downloadFileModel
{
    _downloadFileModel = downloadFileModel;
    
    self.downloadView.model = downloadFileModel;
    
    // 更新frame
    [self updateSubViewFrames];
}

/**
 * 更新imageModel
 */
- (void)setUploadImageModel:(HYUploadImageModel *)uploadImageModel
{
    _uploadImageModel = uploadImageModel;
    
    self.uploadView.updatedImageModel = uploadImageModel;
}

#pragma mark - event selector
/**
 * 按钮点击事件
 */
- (void)btnClick:(UIButton *)btn
{
    // 清空上次的查询结果
    self.resultTextView.text = nil;
    
    // 判断电话号码输入是否为空
    NSString *phoneNumber = self.phoneNumberF.text;
    if (phoneNumber.length == 0) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"电话号码不能为空" inCtr:self];
        return;
    }
    
    switch (btn.tag - 1000) {
        case 0:
            // 同步GET请求
            if (self.syncGetRequestBlock) {
                self.syncGetRequestBlock(phoneNumber);
            }
            break;
        case 1:
            // 同步POST请求
            if(self.syncPostRequestBlock){
                self.syncPostRequestBlock(phoneNumber);
            }
            break;
        case 2:
            // 异步GET请求
            if (self.asyncGetRequestBlock) {
                self.asyncGetRequestBlock(phoneNumber);
            }
            break;
        case 3:
            // 异步POST请求
            if (self.asyncPostRequestBlock) {
                self.asyncPostRequestBlock(phoneNumber);
            }
            break;
            
        default:
            break;
    }
}

/**
 * m3u8下载按钮点击
 */
- (void)toM3u8Controller
{
    HYM3u8VedioDownloadController *ctr = [[HYM3u8VedioDownloadController alloc]init];
    [self.navigationController pushViewController:ctr animated:YES];
    
    if (self.toM3u8DownloadControllerBlock) {
        self.toM3u8DownloadControllerBlock();
    }
}

#pragma mark - netRequest
/**
 * 上传图片到服务器
 */
- (void)uploadImageToServerSuccess:(void (^)(void))success
{
    __weak typeof(self) weakSelf = self;
    [HYToast toastWithMessage:@"上传图片"];
    weakSelf.uploadImageModel.status = uploadStatusUploading;
    weakSelf.uploadImageModel = weakSelf.uploadImageModel;
    if ([HYGeneralSingleTon share].accessToken == nil) {
        // 获取accessToken
        [self reloadAccessToken:^(NSString *token) {
            // 登录成功
            [weakSelf uploadImageRequestSuccess:success];
        }];
    }else {
        // 已经获取到token 获取图片
        [self uploadImageRequestSuccess:success];
    }
}

/**
 * 上传图片
 * uploadImageSuccess 上传图片成功回调
 */
- (void)uploadImageRequestSuccess:(void (^)(void))uploadImageSuccess
{
    __weak typeof(self) weakSelf = self;
    NSDictionary *parameters = @{@"access_token":[HYGeneralSingleTon share].accessToken,@"type":@"image"};
    if (self.uploadImageBlock) {
        // 上传图片成功回调
        void (^success)(NSString *) = ^(NSString *response){
            NSDictionary *dic = [response toJsonData];
            int errorCode = [dic[@"errcode"] intValue];
            if (errorCode == 45001) {
                // 图片大小超过2M 需要压缩才能上传
                [HYToast toastWithMessage:@"图片太大,压缩后重新上传"];
                [weakSelf compressImageComplete:^{
                   // 压缩完成 重新上传
                    [weakSelf uploadImageRequestSuccess:uploadImageSuccess];
                }];
            }else if (errorCode == 42001) {
                // accessToken失效
                [weakSelf reloadAccessToken:^(NSString *token) {
                    // 重新获取accessToken成功
                    [weakSelf uploadImageRequestSuccess:uploadImageSuccess];
                }];
            }else if (errorCode == 0){
                // 上传图片成功
                [HYToast toastWithMessage:@"图片上传成功"];
                NSString *imageId = dic[@"media_id"];
                weakSelf.uploadImageModel.media_id = imageId;
                weakSelf.uploadImageModel.url = dic[@"url"];
                NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval currentTimeInterval = [now timeIntervalSince1970];
                weakSelf.uploadImageModel.uploadTimestamp = currentTimeInterval;
                [weakSelf.uploadImageModel reloadImageStatus:^{
                    weakSelf.uploadImageModel = weakSelf.uploadImageModel;
                }];
                
                if (uploadImageSuccess) {
                    uploadImageSuccess();
                }
            }else {
                weakSelf.uploadImageModel.status = uploadStatusUnload;
                weakSelf.uploadImageModel = weakSelf.uploadImageModel;
                [HYToast toastWithMessage:@"上传图片失败"];
            }
        };
        
        // 上传图片信息
        void (^faile)(void) = ^{
            weakSelf.uploadImageModel.status = uploadStatusUnload;
            weakSelf.uploadImageModel = weakSelf.uploadImageModel;
            [HYToast toastWithMessage:@"上传图片失败"];
        };
        
        // 上传进度更新
        void (^progressBlock)(double) = ^(double progress){
            weakSelf.uploadImageModel.progress = progress;
            weakSelf.uploadImageModel = weakSelf.uploadImageModel;
        };
        
        // 上传完成回调
        void (^finish)(NSString *) = ^(NSString *responseContent){
            NSDictionary *dict = [responseContent toJsonData];
            if ([dict[@"errcode"] intValue] == 0) {
                [weakSelf.uploadImageModel reloadImageStatus:^{
                    weakSelf.uploadImageModel = weakSelf.uploadImageModel;
                }];
            }
        };
        
        NSData *uploadData = UIImagePNGRepresentation(weakSelf.uploadImageModel.image);
        NSLog(@"上传图片大小:%@",[NSByteCountFormatter stringFromByteCount:uploadData.length countStyle:NSByteCountFormatterCountStyleFile]);
        self.uploadImageBlock(UploadLongTimeFileUrl, parameters,uploadData,success,faile,progressBlock,finish);
    }
}

/**
 * 刷新accessToken
 */
- (void)reloadAccessToken:(void (^)(NSString *token))reloadSuccess
{
    __weak typeof(self) weakSelf = self;
    [[HYGeneralSingleTon share] reloadAccessTokenCoreCode:^(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void)) {
        if (weakSelf.requestAccessTokenBlock) {
            // 获取token成功
            void (^getTokenSuccess)(NSData *) = ^(NSData *result){
                if (success) {
                    success(result);
                }
                
                if (reloadSuccess) {
                    reloadSuccess([HYGeneralSingleTon share].accessToken);
                }
            };
            
            // 获取token失败回调
            void (^getTokenFaile)(void) = ^{
                weakSelf.uploadImageModel.status = uploadStatusUnload;
                weakSelf.uploadImageModel = weakSelf.uploadImageModel;
                
                if (faile) {
                    faile();
                }
            };
            weakSelf.requestAccessTokenBlock(urlString, parameters, getTokenSuccess, getTokenFaile);
        }
    }];
}

/**
 * 从服务器获取image列表
 */
- (void)loadImageListFromServer:(void (^)(void))success
{
    __weak typeof(self) weakSelf = self;
    [[HYGeneralSingleTon share].imageListArray removeAllObjects];
    if ([HYGeneralSingleTon share].accessToken == nil) {
        // 获取token
        [self reloadAccessToken:^(NSString *token) {
            // 获取token 成功
            [weakSelf loadImageListWithPageIndex:0 success:success];
        }];
    }else {
        [weakSelf loadImageListWithPageIndex:0 success:success];
    }
}

/**
 * 加载素材列表
 */
- (void)loadImageListWithPageIndex:(int)pageIndex success:(void (^)(void))loadSuccess
{
    __weak typeof(self) weakSelf = self;
    if (self.loadImageListBlock) {
        __block int currentPageIndex = pageIndex;
        // 请求url和参数
        NSString *url = [NSString stringWithFormat:@"%@?access_token=%@",GetImageListUrl,[HYGeneralSingleTon share].accessToken];
        NSDictionary *parameters = @{@"type":@"image",@"offset":[NSNumber numberWithInt:pageIndex * 20],@"count":[NSNumber numberWithInt:20]};
        
        // 请求成功回调
        void (^requestSuccess)(NSData *) = ^(NSData *responseData){
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            int errorCode = [result[@"errcode"] intValue];
            if (errorCode == 42001) {
                // token失效
                [weakSelf reloadAccessToken:^(NSString *token) {
                    [weakSelf loadImageListWithPageIndex:pageIndex success:loadSuccess];
                }];
            }else if (errorCode == 0){
                if (result) {
                    NSArray *lists = result[@"item"];
                    if (lists.count > 0) {
                        for (NSDictionary *dict in lists) {
                            HYServerImageModel *model = [HYServerImageModel imageModelWithDic:dict];
                            [[HYGeneralSingleTon share].imageListArray addObject:model];
                        }
                        
                        // 请求下一页数据
                        [weakSelf loadImageListWithPageIndex:++currentPageIndex success:loadSuccess];
                    }else {
                        // 数据已经请求完了
                        if (loadSuccess) {
                            loadSuccess();
                        }
                    }
                }else {
                    NSLog(@"加载image列表为空");
                }
            }else {
                NSLog(@"其他错误");
            }
            
        };
        self.loadImageListBlock(url, parameters,requestSuccess);
    }
}

#pragma mark - other
/**
 * 动画弹出视频播放界面第一步动画效果(从播放按钮出以抛物线的动画形式到屏幕中间)
 * animationImage 动画image
 * animationViewRadius 动画最终显示时候的圆形的半径
 * startPoint 动画开始位置
 * endPoint 动画结束位置
 * completion 动画结束回调
 */
- (void)showPlayViewAnimationViewRadius:(CGFloat)animationViewRadius
                              playVedio:(BOOL)playVedio
                        originImageView:(UIImageView *)originImageView
                        completion:(void (^)(void))completion
{
    [self animationShow:YES playVedio:playVedio originImageView:originImageView delete:NO animationViewRadius:animationViewRadius completion:completion];
}

/**
 * 动画弹出视频播放界面第一步动画效果(从播放按钮出以抛物线的动画形式到屏幕中间)
 * animationImage 动画image
 * animationViewRadius 动画最终显示时候的圆形的半径
 * startPoint 动画开始位置
 * endPoint 动画结束位置
 * completion 动画结束回调
 */
- (void)hiddenPlayViewAnimationViewRadius:(CGFloat)animationViewRadius
                                playVedio:(BOOL)playVedio
                          originImageView:(UIImageView *)originImageView
                                   delete:(BOOL)delete
{
    [self animationShow:NO playVedio:playVedio originImageView:originImageView delete:delete animationViewRadius:animationViewRadius completion:nil];
}

/**
 * 抛物线动画
 * show 展示/消失
 * playVedio 是否是播放视频
 * originImageView 点击的imageView
 * delete 是否是删除视频
 * animationViewRadius 半径
 * completion 动画完成
 */
- (void)animationShow:(BOOL)show
            playVedio:(BOOL)playVedio
      originImageView:(UIImageView *)originImageView
               delete:(BOOL)delete
       animationViewRadius:(CGFloat)animationViewRadius
                completion:(void (^)(void))completion
{
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    CGPoint controlPoint = CGPointZero;
    
    if (playVedio) {
        UIButton *btn = nil;
        for (UIView *subView in self.downloadView.subviews.firstObject.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                btn = (UIButton *)subView;
                break;
            }
        }
        CGRect startReact = [self.downloadView convertRect:btn.frame toView:self.view];
        startPoint = CGPointMake(startReact.origin.x + startReact.size.width * 0.5, startReact.origin.y + startReact.size.height * 0.5);
    }else {
        CGRect rect = [self.uploadView convertRect:originImageView.frame toView:self.view];
        UIScrollView *scroll = (UIScrollView *)self.uploadView.subviews.firstObject;
        startPoint = CGPointMake(rect.origin.x + rect.size.width * 0.5 - scroll.contentOffset.x, rect.origin.y + rect.size.height * 0.5);
    }
    
    endPoint = self.view.center;
    if (!show) {
        CGPoint tempPoint = startPoint;
        startPoint = endPoint;
        endPoint = tempPoint;
    }
    
    if (delete) {
        endPoint = CGPointMake(-100, endPoint.y);
    }
    
    if (playVedio) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        controlPoint = CGPointMake(screenSize.width - 50,screenSize.height * 0.2 + (startPoint.y - endPoint.y) * 0.5 + 150);
    }else {
        CGFloat minX = MIN(startPoint.x, endPoint.x);
        CGFloat minY = MIN(startPoint.y, endPoint.y);
        controlPoint = CGPointMake(minX + fabs(startPoint.x - endPoint.x) * 0.5, minY + fabs(startPoint.y - endPoint.y) * 0.5);
    }
    
    // 创建shapeLayer
    CGRect animationViewFrame = CGRectMake(startPoint.x - animationViewRadius, startPoint.y - animationViewRadius, animationViewRadius * 2.0, animationViewRadius * 2.0);
    CAShapeLayer *animationLayer = [[CAShapeLayer alloc] init];
    animationLayer.frame = animationViewFrame;
    animationLayer.cornerRadius = animationViewRadius;
    animationLayer.masksToBounds = YES;
    animationLayer.contents = (id)self.screenShotImage.CGImage;
    [self.view.layer addSublayer:animationLayer];
    
    // 创建移动轨迹
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:startPoint];
    [movePath addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    // 轨迹动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGFloat durationTime = 0.5; // 动画时间1秒
    pathAnimation.duration = durationTime;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.path = movePath.CGPath;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    // 创建逐渐放大/缩小动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    CGFloat fromV = 0.0;
    CGFloat toV = 1.0;
    if (!show || delete) {
        fromV = 1.0;
        toV = 0.0;
    }
    scaleAnimation.duration = 0.6;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:fromV];
    scaleAnimation.toValue = [NSNumber numberWithFloat:toV];
    
    // 添加轨迹动画
    [animationLayer addAnimation:pathAnimation forKey:nil];
    [animationLayer addAnimation:scaleAnimation forKey:nil];
    
    // 动画结束后执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durationTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [animationLayer removeFromSuperlayer];
        if (completion) {
            completion();
        }
    });
}

@end
