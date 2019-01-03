//
//  HYNetRequestBaseController.m
//  OCADV
//
//  Created by MrChen on 2018/12/24.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import "HYNetRequestBaseController.h"
#import "HYDownloadFileModel.h"
#import "HYPlayVideoController.h"

@interface HYNetRequestBaseController ()

// 电话号码输入框
@property (nonatomic, weak) UITextField *phoneNumberF;

// 结果显示框
@property (nonatomic, weak) UITextView *resultTextView;

// 下载视图
@property (nonatomic, weak) HYDownloadView *downloadView;

// 当前view添加上毛玻璃效果后的截图(视频下载完以后点击播放动画用)
@property (nonatomic, strong) UIImage *screenShotImage;
@end

@implementation HYNetRequestBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建子视图
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateDownloadUI];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/**
 * 通过读取本地下载的文件的大小更新下载界面
 */
- (void)updateDownloadUI
{
    HYDownloadFileModel *downloadModel = self.downloadView.model;
    
    // 根据下载存储路径从磁盘查询是否已经下载过和已经下载的大小,用于断点续传
    NSString *path = [HYMoviesResolver share].netDownloadFileSavePath;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        long long downloadLength = [[manager attributesOfItemAtPath:path error:nil] fileSize];
        if (downloadLength > 0) {
            downloadModel.downloadProgress = (double)downloadLength/downloadModel.totalLength;
            downloadModel.downloadLength = downloadLength;
            if (downloadModel.downloadProgress == 1) {
                // 已经下载完成
                self.downloadState = fileStateDownloaded;
            }else {
                // 下载过一部分
                self.downloadState = fileStateUnDwonload;
            }
        }
    }else {
        downloadModel.downloadLength = 0;
        downloadModel.downloadProgress = 0;
        
        self.downloadState = fileStateUnDwonload;
    }
    
    // 通知model 刷新界面
    self.downloadView.model = downloadModel;
}

/**
 * 创建子视图
 */
- (void)createSubviews
{
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scroll];
    CGFloat padding = 10.0;
    
    // 电话号码输入框
    UITextField *phoneTextF = [[UITextField alloc]initWithFrame:CGRectMake(padding, padding, ScWidth - padding * 2.0, 30)];
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
    
    // 下载视图
    __weak typeof(self) weakSelf = self;
    HYDownloadView *downloadView = [[HYDownloadView alloc]initWithFrame:CGRectMake(padding, CGRectGetMaxY(resultTextView.frame) + padding, ScWidth - padding * 2.0, 100.0)];
    [scroll addSubview:downloadView];
    self.downloadView = downloadView;
    // 设置下载数据模型
    HYDownloadFileModel *downloadModel = [HYMoviesResolver share].movies.lastObject;
    downloadView.model = downloadModel;
    // 开始下载回调
    downloadView.downloadStartBlock = ^{
        if (weakSelf.downloadStartBlock) {
            weakSelf.downloadStartBlock(downloadModel.downloadUrl, @"");
        }
    };
    // 暂停下载回调
    downloadView.downloadPauseBlock = ^{
        if (weakSelf.downloadPauseBlock) {
            weakSelf.downloadPauseBlock(downloadModel.downloadUrl);
        }
    };
    // 继续下载回调
    downloadView.downloadResumeBlock = ^{
        if (weakSelf.downloadResumeBlock) {
            weakSelf.downloadResumeBlock(downloadModel.downloadUrl);
        }
    };
    // 播放回调
    downloadView.playBlock = ^{
        // 动画弹出播放视频界面
    
        // 第一步动画 抛物线动画移动
        CGFloat radius = 30.0;
        [weakSelf showPlayViewAnimationViewRadius:radius completion:^{
            // 第一步动画完成,开始第二步扩散圆形展示动画(使用自定义present controller转场动画做)
            HYPlayVideoController *playVideoCtr = [[HYPlayVideoController alloc]init];
            playVideoCtr.fromReact = CGRectMake(weakSelf.view.center.x - radius, weakSelf.view.center.y - radius, radius * 2.0, radius * 2.0);
            playVideoCtr.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
            [weakSelf presentViewController:playVideoCtr animated:YES completion:nil];

            // 播放视频界面消失以后动画
            playVideoCtr.dismissComplete = ^(BOOL deleteVideo) {
                if (deleteVideo) {
                    // 删除视频
                    [weakSelf hiddenPlayViewAnimationViewRadius:radius delete:YES];
                    [weakSelf updateDownloadUI];
                }else {
                    // 关闭视频页面
                    [weakSelf hiddenPlayViewAnimationViewRadius:radius delete:NO];
                }
            };
        }];
        
        // 其他额外需求
        if (weakSelf.playBlock) {
            weakSelf.playBlock();
        }
    };
    
    scroll.contentSize = CGSizeMake(ScWidth, CGRectGetMaxY(downloadView.frame));
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
 * 绑定结果数据
 */
- (void)setRequestResult:(NSString *)requestResult
{
    _requestResult = requestResult;
    self.resultTextView.text = requestResult;
}

/**
 * 设置下载进度
 */
- (void)setDownloadProgress:(double)downloadProgress
{
    _downloadProgress = downloadProgress;
    HYDownloadFileModel *model = self.downloadView.model;
    model.downloadProgress = downloadProgress;
    self.downloadView.model = model;
}

/**
 * 更新下载状态
 */
- (void)setDownloadState:(fileState)downloadState
{
    _downloadState = downloadState;
    self.downloadView.state = downloadState;
}

/**
 * 更新下载文件的名字
 */
- (void)setDownloadFileName:(NSString *)downloadFileName
{
    _downloadFileName = downloadFileName;
    HYDownloadFileModel *model = self.downloadView.model;
    model.name = downloadFileName;
    self.downloadView.model = model;
}

/**
 * 更新下载文件总大小
 */
- (void)setDownloadFileTotalSize:(long long)downloadFileTotalSize
{
    _downloadFileTotalSize = downloadFileTotalSize;
    HYDownloadFileModel *model = self.downloadView.model;
    model.totalLength = downloadFileTotalSize;
    self.downloadView.model = model;
}

/**
 * 更新下载文件已经下载的大小
 */
- (void)setDownloadFileSaveSize:(long long)downloadFileSaveSize
{
    _downloadFileSaveSize = downloadFileSaveSize;
    HYDownloadFileModel *model = self.downloadView.model;
    model.downloadLength = downloadFileSaveSize;
    self.downloadView.model = model;
}

#pragma mark - event selector
/**
 * 按钮点击事件
 */
- (void)btnClick:(UIButton *)btn
{
    // 判断电话号码输入是否为空
    NSString *phoneNumber = self.phoneNumberF.text;
    if (phoneNumber.length == 0) {
        [HYAlertUtil showAlertTitle:@"提示" msg:@"电话号码不能为空" inCtr:self];
        return;
    }
    
    // 清空结果显示框里面的内容
    self.requestResult = @"";
    
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

#pragma mark - custom method
/**
 * 动画弹出视频播放界面第一步动画效果(从播放按钮出以抛物线的动画形式到屏幕中间)
 * animationImage 动画image
 * animationViewRadius 动画最终显示时候的圆形的半径
 * startPoint 动画开始位置
 * endPoint 动画结束位置
 * completion 动画结束回调
 */
- (void)showPlayViewAnimationViewRadius:(CGFloat)animationViewRadius
                        completion:(void (^)(void))completion
{
    [self animationShow:YES delete:NO animationViewRadius:animationViewRadius completion:completion];
}

/**
 * 动画弹出视频播放界面第一步动画效果(从播放按钮出以抛物线的动画形式到屏幕中间)
 * animationImage 动画image
 * animationViewRadius 动画最终显示时候的圆形的半径
 * startPoint 动画开始位置
 * endPoint 动画结束位置
 * completion 动画结束回调
 */
- (void)hiddenPlayViewAnimationViewRadius:(CGFloat)animationViewRadius delete:(BOOL)delete
{
    [self animationShow:NO delete:delete animationViewRadius:animationViewRadius completion:nil];
}

/**
 * 抛物线动画
 * show 展示/消失
 * delete 是否是删除视频
 * animationViewRadius 半径
 * completion 动画完成
 */
- (void)animationShow:(BOOL)show
               delete:(BOOL)delete
       animationViewRadius:(CGFloat)animationViewRadius
                completion:(void (^)(void))completion
{
    UIButton *btn = nil;
    for (UIView *subView in self.downloadView.subviews.firstObject.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            btn = (UIButton *)subView;
            break;
        }
    }
    CGRect startReact = [self.downloadView convertRect:btn.frame toView:self.view];
    CGPoint startPoint = CGPointMake(startReact.origin.x + startReact.size.width * 0.5, startReact.origin.y + startReact.size.height * 0.5);
    CGPoint endPoint = self.view.center;
    if (!show) {
        CGPoint tempPoint = startPoint;
        startPoint = endPoint;
        endPoint = tempPoint;
    }
    
    if (delete) {
        endPoint = CGPointMake(-100, endPoint.y);
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
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [movePath addQuadCurveToPoint:endPoint controlPoint:CGPointMake(screenSize.width - 50,screenSize.height * 0.2 + (startPoint.y - endPoint.y) * 0.5 + 150)];
    
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
