//
//  HYUploadView.m
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYUploadView.h"
#import "HYPhotoAlbumManager.h"

#define MarginWidth 10.0
#define Height 150.0

@interface HYUploadView ()

// 滚动视图
@property (nonatomic, strong) UIScrollView *scrollView;

// 图片数组
@property (nonatomic, strong) NSMutableArray *imagesArray;

// 所有的imageView
@property (nonatomic, strong, readwrite) NSMutableArray <HYUploadImageView *>*imageViewListArray;

// 所有的imageView
//@property (nonatomic, strong, readwrite) NSMutableArray *imageViewListArray;

// 记录最后一张图片的maxX值 为了计算下一张图片的x
@property (nonatomic, assign) CGFloat lastImageViewMaxX;

@end

@implementation HYUploadView
@synthesize updatedImageModel = _updatedImageModel;

/**
 * 初始化
 */
- (instancetype)initWithY:(CGFloat)y
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(MarginWidth, y, ScWidth - MarginWidth * 2.0, Height);
        self.imagesArray = [NSMutableArray array];
        self.lastImageViewMaxX = 0;

        // 创建子视图
        [self createScrollView];
        
        // 加载相册照片
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD showWithStatus:@"加载照片中..."];
        [self loadAlbumImages:^(HYUploadImageModel *imageModel) {
            // 获取到一张照片调用一次
            [weakSelf createImageView:imageModel];
        } complete:^{
            // 所有图片加载完成回调 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KLOADIMAGECOMPLETE object:nil];
        }];
    }
    return self;
}

#pragma mark - setter
/**
 * 更新后的imageModel
 */
- (void)setUpdatedImageModel:(HYUploadImageModel *)updatedImageModel
{
    _updatedImageModel = updatedImageModel;
    
    HYUploadImageView *imageView = [self.scrollView viewWithTag:updatedImageModel.imageIndex];
    imageView.model = updatedImageModel;
}

/**
 * 获取所有的imageView
 */
- (NSMutableArray<HYUploadImageModel *> *)imageViewListArray
{
    if (_imagesArray == nil) {
        _imagesArray = [NSMutableArray array];
    }
    
    [_imagesArray removeAllObjects];
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView isKindOfClass:[HYUploadImageView class]]) {
            [_imagesArray addObject:subView];
        }
    }
    
    return _imagesArray;
}

#pragma mark - create subviews
/**
 * 创建scrollView
 */
- (void)createScrollView
{
    // 创建背景视图
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    self.scrollView.layer.borderWidth = 3.0;
    self.scrollView.layer.borderColor = ColorMain.CGColor;
    self.scrollView.layer.cornerRadius = 6.0;
    [self addSubview:self.scrollView];
}

/**
 * 创建imageViews
 */
- (void)createImageView:(HYUploadImageModel *)imageModel
{
    __weak typeof(self) weakSelf = self;
    
    // 记录图片索引
    NSInteger imageIndex = self.imagesArray.count + 1;
    imageModel.imageIndex = imageIndex;
    
    // 创建imageView
    CGFloat imageVH = CGRectGetHeight(self.scrollView.frame) - MarginWidth;
    CGFloat imageVY = MarginWidth * 0.5;
    
    NSInteger index = self.imagesArray.count;
    if (index < 0) return;
    CGSize imageSize = imageModel.image.size;
    CGFloat imageVW = imageVH / imageSize.height * imageSize.width;
    CGFloat imageVX = self.lastImageViewMaxX + MarginWidth * 0.5;
    HYUploadImageView *imageView = [[HYUploadImageView alloc]initWithFrame:CGRectMake(imageVX, imageVY, imageVW, imageVH)];
    imageView.startUploadImageBlock = ^{
        if (weakSelf.uploadImageBlock) {
            weakSelf.uploadImageBlock(imageModel);
        }
    };
    __weak typeof(HYUploadImageView *) weakImageView = imageView;
    imageView.checkUploadedImage = ^(HYUploadImageModel * _Nonnull imageModel) {
        if (self.checkUploadedImage) {
            self.checkUploadedImage(imageModel,weakImageView);
        }
    };
    imageView.tag = imageIndex;
    imageView.model = imageModel;
    
    [self.scrollView addSubview:imageView];
    self.lastImageViewMaxX = CGRectGetMaxX(imageView.frame);
    
    self.scrollView.contentSize = CGSizeMake(self.lastImageViewMaxX + MarginWidth * 0.5, self.scrollView.bounds.size.height);
    
    // 保存model
    [self.imagesArray addObject:imageModel];
}

/**
 * 销毁用到的计时器
 */
- (void)destroyTimer
{
    for (UIView *imageView in self.scrollView.subviews) {
        if ([imageView isKindOfClass:[HYUploadImageView class]]) {
            [(HYUploadImageView *)imageView destroyTimer];
        }
    }
}

#pragma mark - load album photos
// 读取相册照片 异步读取
- (void)loadAlbumImages:(void (^)(HYUploadImageModel *imageModel))loadResult complete:(void (^)(void))complete
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        HYPhotoAlbumManager *photoManager = [HYPhotoAlbumManager shareManager];
        [photoManager getAllPhototsComplete:^(NSArray<PHAsset *> *result) {
            for (PHAsset *asset in result) {
                UIImage *image = [photoManager imageWithAssert:asset synchronous:YES original:YES complete:nil];
                NSString *imageName = [photoManager imageNameWithPHAssert:asset];
                HYUploadImageModel *model = [[HYUploadImageModel alloc]init];
                model.image = image;
                model.imageName = imageName;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (loadResult) {
                        loadResult(model);
                    }
                });
            }
            
            // 加载图片完成回调
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete();
                }
            });
        }];
    });
}


@end
