//
//  HYUploadImageView.m
//  OCADV
//
//  Created by MrChen on 2019/1/4.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYUploadImageView.h"

@interface HYUploadImageView ()

// 上传图片按钮
@property (nonatomic, strong) UIButton *uploadBtn;

// 图片索引标识label
@property (nonatomic, strong) UILabel *imageIndexLabel;

// 图片大小label
@property (nonatomic, strong) UILabel *imageSizeLabel;

// 图片上传时间label
@property (nonatomic, strong) UILabel *uploadDateLabel;

// 计时器
@property (nonatomic, strong) NSTimer *timer;

// 动画计时
@property (nonatomic, assign) NSInteger animationTime;
@property (nonatomic, assign) NSInteger overTime;

// 动画是否开启了
@property (nonatomic, assign) BOOL animationOpen;

// 环形进度条背景layer
@property (nonatomic, strong) CAShapeLayer *progressBgLayer;

// 环形进度条layer
@property (nonatomic, strong) CAShapeLayer *progressLayer;

// 进度条label
@property (nonatomic, strong) UILabel *progressLabel;

// 查看图标(标示该图片已上传过 可以点击查看)
@property (nonatomic, strong) UIImageView *checkImageView;

@end

@implementation HYUploadImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 创建子视图
        [self createSubviews];
        
        // 创建并添加计时器
        [self createTimer];
    }
    return self;
}

#pragma mark - setter getter
/**
 * 绑定数据
 */
- (void)setModel:(HYUploadImageModel *)model
{
    _model = model;
    
    // 图片
    self.image = model.image;
    
    // 图片大小
    self.imageSizeLabel.text = model.imageLengthFormate;

    // 图片索引
    self.imageIndexLabel.text = [NSString stringWithFormat:@"%lu",model.imageIndex];
    
    // 进度更新
    [self updateProgressViewPersent:model.progress];
    
    // 图片上传状态
    switch (model.status) {
        case uploadStatusUnload:
            // 未上传
            [self removeProgressView];
            [self startAlphaLightAnimation];
            self.checkImageView.hidden = YES;
            self.uploadDateLabel.hidden = NO;
            self.uploadDateLabel.text = @"未上传";
            break;
        case uploadStatusUploading:
            // 正在上传
            [self addProgressView];
            [self stopAlphaLightAnimation];
            self.checkImageView.hidden = YES;
            self.uploadDateLabel.hidden = YES;
            break;
        case uploadStatusLoad:{
            // 上传过
            [self removeProgressView];
            [self stopAlphaLightAnimation];
            self.checkImageView.hidden = NO;
            self.uploadDateLabel.hidden = NO;
            
            // 上传时间
            NSString *uploadDate = [model.uploadDate stringByAppendingString:@"上传"];
            CGFloat heigth = [uploadDate sizeWithFont:self.uploadDateLabel.font maxSize:CGSizeMake(self.bounds.size.width, 10000)].height;
            self.uploadDateLabel.viewHeight = heigth;
            self.uploadDateLabel.viewY = self.bounds.size.height - heigth - 5.0;
            self.uploadDateLabel.text = uploadDate;;
        }
            break;
        default:
            break;
    }
}

#pragma mark - create subviews
/**
 * 创建子视图
 */
- (void)createSubviews
{
    // 默认动画关闭
    self.animationOpen = NO;
    
    // 上传图片按钮
    _uploadBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _uploadBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    [_uploadBtn setBackgroundImage:[UIImage imageNamed:@"upload"] forState:UIControlStateNormal];
    [_uploadBtn addTarget:self action:@selector(uploadBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _uploadBtn.alpha = 0.0;
    _uploadBtn.userInteractionEnabled = NO;
    [self addSubview:_uploadBtn];
    
    // 创建图片索引标识label
    self.imageIndexLabel = [[UILabel alloc]initWithFrame:CGRectMake(5.0, 5.0, 20.0, 20.0)];
    self.imageIndexLabel.layer.cornerRadius = 10.0;
    self.imageIndexLabel.layer.borderWidth = 2.0;
    self.imageIndexLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageIndexLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.imageIndexLabel.textColor = [UIColor whiteColor];
    self.imageIndexLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.imageIndexLabel];
    
    // 创建图片大小显示label
    CGFloat imageSizeLabelX = CGRectGetMaxX(self.imageIndexLabel.frame);
    CGFloat imageSizeLabelW = self.bounds.size.width - imageSizeLabelX - 5.0;
    CGFloat imageSizeLabelH = CGRectGetHeight(self.imageIndexLabel.frame);
    CGFloat imageSizeLabelY = CGRectGetMinY(self.imageIndexLabel.frame);
    self.imageSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageSizeLabelX, imageSizeLabelY, imageSizeLabelW, imageSizeLabelH)];
    self.imageSizeLabel.backgroundColor = [UIColor clearColor];
    self.imageSizeLabel.textColor = [UIColor whiteColor];
    self.imageSizeLabel.font = [UIFont systemFontOfSize:12.0];
    self.imageSizeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.imageSizeLabel];
    
    // 查看图标
    CGSize size = self.bounds.size;
    CGFloat checkImgW = 20.0;
    CGFloat checkImgH = checkImgW;
    CGFloat margin = 10.0;
    self.checkImageView = [[UIImageView alloc]initWithFrame:CGRectMake(size.width - checkImgW - margin, size.height - checkImgH - margin, checkImgW, checkImgH)];
    self.checkImageView.image = [UIImage imageNamed:@"check"];
    self.checkImageView.hidden = YES;
    [self addSubview:self.checkImageView];
    
    // 上传时间
    CGFloat uploadDateLabelH = 20.0;
    CGFloat uploadDateLabelY = self.bounds.size.height - uploadDateLabelH - 5.0;
    self.uploadDateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, uploadDateLabelY, self.bounds.size.width, uploadDateLabelH)];
    self.uploadDateLabel.numberOfLines = 0;
    self.uploadDateLabel.backgroundColor = [UIColor clearColor];
    self.uploadDateLabel.textColor = [UIColor whiteColor];
    self.uploadDateLabel.font = [UIFont systemFontOfSize:12.0];
    self.uploadDateLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.uploadDateLabel];
    
    // 图片添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [self addGestureRecognizer:tapGesture];
    // 开启响应点击事件
    self.userInteractionEnabled = YES;
    
    // 创建环形进度条视图
    [self createCircleProgressView];
}

/**
 * 开启呼吸灯动画
 */
- (void)startAlphaLightAnimation
{
    if (!self.animationOpen) {
        // 开启动画
        self.animationTime = 0;
        [self addAlphaLightAnimation];
        
        // 开启计时器
        [self.timer setFireDate:[NSDate distantPast]];
        self.animationOpen = YES;
        
        self.uploadBtn.userInteractionEnabled = NO;
    }
}

/**
 * 停止呼吸灯动画
 */
- (void)stopAlphaLightAnimation
{
    if (self.animationOpen) {
        // 停止定时器 停止呼吸灯动画
        [self.timer setFireDate:[NSDate distantFuture]];
        self.animationTime = 0;
        [self.uploadBtn.layer removeAllAnimations];
        self.animationOpen = NO;
    }
}

/**
 * 添加呼吸灯动画
 */
- (void)addAlphaLightAnimation
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 2.0;//动画循环的时间，也就是呼吸灯效果的速度
    animation.repeatCount = 1;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.uploadBtn.layer addAnimation:animation forKey:@"aAlpha"];
}


/**
 * 创建环形进度条视图
 */
- (void)createCircleProgressView
{
    // 以宽 高中最小者作为标准作为环形进度条的半径
    CGSize size = self.bounds.size;
    CGFloat min = MIN(size.width, size.height);
    CGFloat radius = min - 40.0;
    
    //第一步，通过UIBezierPath设置圆形的矢量路径
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius, radius)];
    
    //第二步，用CAShapeLayer沿着第一步的路径画一个完整的环（颜色灰色，起始点0，终结点1）
    _progressBgLayer = [CAShapeLayer layer];
    _progressBgLayer.frame = CGRectMake(0, 0, radius, radius);//设置Frame
    _progressBgLayer.position = CGPointMake(size.width * 0.5, size.height * 0.5);//居中显示
    _progressBgLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色=透明色
    _progressBgLayer.lineWidth = 5.f;//线条大小
    _progressBgLayer.strokeColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0].CGColor;//线条颜色
    _progressBgLayer.strokeStart = 0.f;//路径开始位置
    _progressBgLayer.strokeEnd = 1.f;//路径结束位置
    _progressBgLayer.path = circle.CGPath;//设置bgLayer的绘制路径为circle的路径
    
    //第三步，用CAShapeLayer沿着第一步的路径画一个红色的环形进度条，但是起始点=终结点=0，所以开始不可见
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = CGRectMake(0, 0, radius, radius);
    _progressLayer.position = CGPointMake(size.width * 0.5, size.height * 0.5);
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineWidth = 3.f;
    _progressLayer.strokeColor = [UIColor greenColor].CGColor;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.lineJoin = kCALineJoinRound;
    _progressLayer.path = circle.CGPath;
    
    // 进度条label
    _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, radius, 30.0)];
    _progressLabel.font = [UIFont systemFontOfSize:16.0];
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.center = _progressLayer.position;
}

/**
 * 添加进度条
 */
- (void)addProgressView
{
    if (!_progressLabel.superview) {
        [self addSubview:_progressLabel];
        [self.layer addSublayer:_progressBgLayer];
        [self.layer addSublayer:_progressLayer];
    }
}

/**
 * 去除进度条
 */
- (void)removeProgressView
{
    if (_progressLabel.superview) {
        [_progressBgLayer removeFromSuperlayer];
        [_progressLayer removeFromSuperlayer];
        [_progressLabel removeFromSuperview];
    }
}

/**
 * 根据百分比更新进度条进度
 */
- (void)updateProgressViewPersent:(double)persent
{
    // 设置百分比进度
    _progressLayer.strokeEnd = persent;
    
    // 根据百分比进度条颜色由红色到绿色渐变
    CGFloat r = 255.0 * (1.0 - persent);
    CGFloat g = 255.0 * persent;
    UIColor *progressColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:0.0 alpha:1.0];
    _progressLayer.strokeColor = progressColor.CGColor;
    _progressLabel.text = [NSString stringWithFormat:@"%.f%%",persent * 100.0];
}

/**
 * 创建并添加计时器
 */
- (void)createTimer
{
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // 关闭计时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

/**
 * 销毁计时器 在控制器销毁的时候销毁计时器,否侧影响当前类实例对象的销毁
 */
- (void)destroyTimer
{
    // 停止计时器
    [self.timer setFireDate:[NSDate distantFuture]];
    
    // 计时器置空
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - lazy loading
- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    }
    
    return _timer;
}

#pragma mark - action
/**
 * 计时器方法
 */
- (void)timerAction
{
    if (!self.animationOpen) {
        self.overTime++;
        
        // 3秒钟以后如果没有操作重新开启呼吸灯动画
        if (self.overTime > 3) {
            if (!self.animationOpen) {
                [UIView animateWithDuration:1 animations:^{
                    self.uploadBtn.alpha = 0.0;
                }completion:^(BOOL finished) {
                    [self startAlphaLightAnimation];
                    self.overTime = 0;
                }];
            }
        }
    }else {
        self.animationTime++;
        if (self.animationTime == (4.0 + 2.0)) {
            // 说明上次动画执行完，两次动画间隔2秒
            self.animationTime = 0;
            [self.uploadBtn.layer removeAllAnimations];
            
            // 添加下一次动画
            [self addAlphaLightAnimation];
        }
    }
}

/**
 * 点击了图片
 */
- (void)tapImage:(id)sender
{
    if (self.model.status == uploadStatusLoad) {
        // 照片已经上传过 查看照片
        if (self.checkUploadedImage) {
            self.checkUploadedImage(self.model);
        }
    }else if(self.model.status == uploadStatusUnload) {
        // 照片未上传过
        if (self.animationOpen) {
            // 停止动画
            [self.uploadBtn.layer removeAllAnimations];
            self.animationOpen = NO;
            self.animationTime = 0;
            self.overTime = 0;
            
            // 显示上传按钮
            self.uploadBtn.alpha = 1.0;
            self.uploadBtn.userInteractionEnabled = YES;
        }else {
            // 动画处于关闭状态,点击图片不做响应,点击上传按钮 开始上传图片
            
        }
    }
}

/**
 * 上传按钮点击
 */
- (void)uploadBtnClick
{
    // 停止呼吸灯动画
    self.animationOpen = YES;
    [self stopAlphaLightAnimation];
    
    // 隐藏上传按钮
    self.uploadBtn.alpha = 0.0;
    
    // 上传照片
    [self addProgressView];
    
    if (self.startUploadImageBlock) {
        self.startUploadImageBlock();
    }
}

@end
