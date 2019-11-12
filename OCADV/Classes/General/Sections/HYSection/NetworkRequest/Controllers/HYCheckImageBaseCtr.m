//
//  HYCheckVideoOrImageBaseCtr.m
//  OCADV
//
//  Created by MrChen on 2019/1/15.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYCheckImageBaseCtr.h"
#import "HYURLConnectionController.h"

@interface HYCheckImageBaseCtr ()

// 背景视图
@property (nonatomic, strong) UIView *playBgView;

// 图片显示
@property (nonatomic, weak) UIImageView *imageView;

// 从服务器获取的image
@property (nonatomic, strong) UIImage *image;

// 删除按钮
@property (nonatomic, weak) UIButton *deleteBtn;

@end

@implementation HYCheckImageBaseCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子视图
    [self createSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    // 加载图片信息
    [self downloadImageFromServerSuccess:^{
        // 更新子视图frame
        [weakSelf reloadImageViewFrame];
        
        // 更新图片列表中对应的image
        [weakSelf reloadUploadImageModel];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissComplete) {
            self.dismissComplete(NO);
        }
    }];
}

#pragma mark - lazy loading
/**
 * 播放视图
 */
- (UIView *)playBgView
{
    if (_playBgView == nil) {
        // 创建磨砂背景视图
        _playBgView = [[UIView alloc]initWithFrame:self.view.bounds];
        _playBgView.backgroundColor = [UIColor clearColor];
        // 设置磨砂效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        blurEffectView.frame = _playBgView.bounds;
        blurEffectView.alpha = 1;
        [_playBgView insertSubview:blurEffectView atIndex:0];
    }
    
    return _playBgView;
}


#pragma mark - custom method
/**
 * 创建子视图
 */
- (void)createSubviews
{
    // 添加背景视图
    [self.view addSubview:self.playBgView];
    
    // 创建图片视图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    imageView.center = self.view.center;
    imageView.image = [UIImage imageNamed:@"placeHold"];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor blackColor];
    [self.playBgView addSubview:imageView];
    self.imageView = imageView;
    
    // 创建删除按钮
    UIButton *deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame), 30, 30)];
    deleteBtn.center = CGPointMake(self.view.center.x, deleteBtn.center.y + 10.0);
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playBgView addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
}

/**
 * 根据image的size刷新imageView的大小
 */
- (void)reloadImageViewFrame
{
    CGSize imageSize = self.image.size;
    CGSize imageViewSize = self.imageView.bounds.size;
    CGFloat imageViewH = imageViewSize.width / imageSize.width * imageSize.height;
    
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.size.height = imageViewH;
    self.imageView.frame = imageViewFrame;
    self.imageView.center = self.view.center;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageView.image = self.image;
    
    CGRect deleteBtnFrame = self.deleteBtn.frame;
    deleteBtnFrame.origin.y = CGRectGetMaxY(self.imageView.frame);
    self.deleteBtn.frame = deleteBtnFrame;
}

/**
 * 更新图片列表中对应的image
 */
- (void)reloadUploadImageModel
{
    HYURLConnectionController *urlConnectionCtr = nil;
    UINavigationController *navCtr = (UINavigationController *)self.presentingViewController;
    for (UIViewController *ctr in navCtr.viewControllers) {
        if ([ctr isKindOfClass:[HYURLConnectionController class]]) {
            urlConnectionCtr = (HYURLConnectionController *)ctr;
            break;
        }
    }
    
//    if (urlConnectionCtr) {
//        urlConnectionCtr.uploadImageModel.image = self.image;
//        urlConnectionCtr.uploadImageModel = urlConnectionCtr.uploadImageModel;
//    }
}



/**
 * 删除图片
 */
- (void)deleteImge
{
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [self deleteImageFromServer:^{
        // 服务器图片删除成功 删除本地图片
        [weakSelf.imageModel deleteImageComplete:^{
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.dismissComplete) {
                    self.dismissComplete(YES);
                }
            }];
        } success:^{
            [HYToast toastWithMessage:@"图片已被删除"];
        } faile:^{
            [HYToast toastWithMessage:@"服务器图片删除成功,本地删除失败"];
        }];
    }];
}

#pragma mark - click action
/**
 * 删除按钮点击
 */
- (void)deleteClick
{
    // 删除图片
    [self deleteImge];
}

#pragma mark - netRequest
/**
 * 从服务器加载图片
 */
- (void)downloadImageFromServerSuccess:(void (^)(void))success
{
    __weak typeof(self) weakSelf = self;
    if (self.loadImageBlock) {
        // 下载图片成功
        void (^downloadSuccess)(NSData *) = ^(NSData *responseData){
            [SVProgressHUD dismiss];
            
            UIImage *image = [UIImage imageWithData:responseData];
            weakSelf.image = image;
            
            if (success) {
                success();
            }
        };
        
        // 加载图片信息失败
        void (^faile)(void) = ^{
            [HYToast toastWithMessage:@"加载失败"];
            [SVProgressHUD dismiss];
        };
        
        [SVProgressHUD show];
        self.loadImageBlock(weakSelf.imageModel.url, downloadSuccess, faile);
    }
}

/**
 * 删除服务器上的图片素材
 */
- (void)deleteImageFromServer:(void (^)(void))success
{
    __weak typeof(self) weakSelf = self;
    if ([HYGeneralSingleTon share].accessToken == nil) {
        // 获取accessToken
        [self reloadAccessToken:^(NSString *token) {
            [weakSelf deleteImageRequestSuccess:success];
        }];
    }else {
        [self deleteImageRequestSuccess:success];
    }
}

/**
 * 删除图片
 * deleteSuccess 删除图片成功回调
 */
- (void)deleteImageRequestSuccess:(void (^)(void))deleteSuccess
{
    __weak typeof(self) weakSelf = self;
    NSDictionary *parameters = @{@"media_id":self.imageModel.media_id};
    if (self.deleteImageBlock) {
        
        // 删除图片成功回调
        void (^success)(NSData *) = ^(NSData *response){
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            int errorCode = [dic[@"errcode"] intValue];
            if (errorCode == 42001) {
                // accessToken失效
                [weakSelf reloadAccessToken:^(NSString *token) {
                    // 重新获取accessToken成功
                    [weakSelf deleteImageRequestSuccess:deleteSuccess];
                }];
            }else if (errorCode == 0){
                // 获取图片信息成功
                [SVProgressHUD dismiss];
                if (deleteSuccess) {
                    deleteSuccess();
                }
            }else {
                [SVProgressHUD dismiss];
                [HYToast toastWithMessage:@"图片删除失败"];
                NSLog(@"删除图片失败:%d",errorCode);
            }
        };
        
        // 删除图片信息失败
        void (^faile)(void) = ^{
            [HYToast toastWithMessage:@"图片删除失败"];
            [SVProgressHUD dismiss];
        };
        
        self.deleteImageBlock([NSString stringWithFormat:@"%@?access_token=%@",DeleteImageUrl,[HYGeneralSingleTon share].accessToken], parameters, success, faile);
    }
}

/**
 * 刷新accessToken
 */
- (void)reloadAccessToken:(void (^)(NSString *token))reloadSuccess
{
    __weak typeof(self) weakSelf = self;
    [[HYGeneralSingleTon share] reloadAccessTokenCoreCode:^(NSString *urlString, NSDictionary *parameters, void (^success)(NSData *response), void (^faile)(void)) {
        // 获取token成功
        void (^getTokenSuccess)(NSData *) = ^(NSData *result){
            if (success) {
                success(result);
            }
            
            if (reloadSuccess) {
                reloadSuccess([HYGeneralSingleTon share].accessToken);
            }
        };
        
        if (weakSelf.requestAccessTokenBlock) {
            weakSelf.requestAccessTokenBlock(urlString, parameters, getTokenSuccess, faile);
        }
    }];
}


@end
