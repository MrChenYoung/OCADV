#import "HYToast.h"

@interface HYToast ()

/// @brief 存放文本的UILabel
@property (strong,nonatomic) UILabel *textLabel;
@property (strong,nonatomic) HYToast *toast;
@property (strong,nonatomic) NSTimer *timer;
/// @brief 记录是否移除
@property (assign,nonatomic) NSInteger currentDate;

// 要显示的所有文本信息队列
@property (nonatomic, strong) NSMutableArray *toastMessages;

@end
@implementation HYToast

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.toast = [[ZFToast alloc] init];
        self.currentDate = 0;
        self.toastMessages = [NSMutableArray array];
        
        /// @brief 创建定时器
        [self createTimer];
        /// @brief 初始化Label
        [self initLabel:@""];
        /// @brief 初始化底层视图
        [self initBottomView];
        NSLog(@"初始化toast");
    }
    
    return self;
}

+ (instancetype)shareToast
{
    static HYToast *toast = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toast = [[HYToast alloc] init];
    });
    
    return toast;
}

/**
 * 从消息队列中取出消息逐条展示
 */
+ (void)toastWithMessage:(NSString *)message
{
    HYToast *toast = [HYToast shareToast];
    if (message) {
        [toast.toastMessages addObject:message];
    }
    
    // 添加toast到当前控制器的view上
    if (toast.superview == nil) {
        UIViewController *vc = [toast getCurrentVC];
        [vc.view addSubview:toast];
        
        // 从消息队列中取出第一条消息显示
        NSString *firstMessage = toast.toastMessages.firstObject;
        [toast updateToastFrame:firstMessage];
        [toast showToastAnimation];
        toast.textLabel.text = firstMessage;
        toast.currentDate = 0;
        
        //启动定时器
        [toast.timer setFireDate:[NSDate distantPast]];
    }
}

/**
 * 动画显示toast
 */
- (void)showToastAnimation
{
    self.alpha = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
    }];
    
//    //将要显示的view按照正常比例显示出来
//    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    //InOut 表示进入和出去时都启动动画
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    //动画时间
//    [UIView setAnimationDuration:0.5f];
//    //先让要显示的view最小直至消失
//    self.transform=CGAffineTransformMakeScale(1.f, 1.f);
//    //启动动画
//    [UIView commitAnimations];
}

/**
 * 动画消失toast
 */
- (void)dismissToastAnimation:(void (^)(void))complete
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    }completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
    
    //将要显示的view按照正常比例显示出来
//    self.transform = CGAffineTransformMakeScale(1.f, 1.f);
//    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
//    //InOut 表示进入和出去时都启动动画
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    //动画时间
//    [UIView setAnimationDuration:0.5f];
//    //先让要显示的view最小直至消失
//    self.transform=CGAffineTransformMakeScale(0.01f, 0.01f);
//    //启动动画
//    [UIView commitAnimations];
}

#pragma mark - 创建定时器
- (void)createTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    //暂停定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

#pragma mark - 初始化Label
- (void)initLabel:(NSString *)message
{
    //获取屏幕宽度
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    //获取屏幕高度
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    /// @brief Label的字号
    UIFont *font = [UIFont systemFontOfSize:15];
    /// @brief 控件的宽
    CGFloat width = screenWidth / 3.0 * 2.0;
    /// @brief Label所需的宽高
    CGSize labelSize = [self calculationTextNeedSize:message andFont:15 andWidth:width];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, labelSize.width, labelSize.height)];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = font;
    self.textLabel.text = message;
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
}

#pragma mark - 初始化底层视图
- (void)initBottomView
{
    //获取屏幕宽度
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    //获取屏幕高度
    CGFloat screenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    self.backgroundColor = [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:0.8];
    self.frame = CGRectMake((screenWidth - self.textLabel.frame.size.width)/2.0, screenHeight - self.textLabel.frame.size.height - 100.0, self.textLabel.frame.size.width + 20, self.textLabel.frame.size.height + 20);
    [self addSubview:self.textLabel];
    //设置ImageView是否可以设为圆角
    self.layer.masksToBounds = YES;
    //设置圆角度数
    self.layer.cornerRadius = 5;
}

#pragma mark - 取到当前控制器
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void)onTimer
{
    self.currentDate++;
    if (self.currentDate == 2) {
        //暂停定时器
        [self.timer setFireDate:[NSDate distantFuture]];
        // 重置时间
        self.currentDate = 0;
        // 移除展示过的消息
        if (self.toastMessages.count > 0) {
            [self.toastMessages removeObjectAtIndex:0];
        }
        
        // 判断消息队列里还有没有消息，如果有更换toast显示文字,如果没有toast消失
        if (self.toastMessages.count > 0) {
            NSString *msg = self.toastMessages.firstObject;
            [self updateToastFrame:msg];
            self.textLabel.text = msg;
            // 开启定时器
            [self.timer setFireDate:[NSDate distantPast]];
        }else {
            [self dismissToastAnimation:^{
                [self removeFromSuperview];
            }];
        }
    }
}

/**
 * 根据消息文字的多少适配toast的大小
 */
- (void)updateToastFrame:(NSString *)message
{
    // 更新label的frame
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = screenWidth / 3.0 * 2.0;
    CGSize labelSize = [self calculationTextNeedSize:message andFont:15 andWidth:width];
    self.textLabel.frame = CGRectMake(10, 10, labelSize.width, labelSize.height);
    
    // 更新toast的frame
    self.frame = CGRectMake((screenWidth - self.textLabel.frame.size.width)/2.0, screenHeight - self.textLabel.frame.size.height - 100.0, self.textLabel.frame.size.width + 20, self.textLabel.frame.size.height + 20);
}

#pragma mark - 计算文本所需大小
- (CGSize)calculationTextNeedSize:(NSString *)text andFont:(CGFloat)font andWidth:(CGFloat)width
{
    CGSize labelSize = [text sizeWithFont: [UIFont boldSystemFontOfSize:font]
                        constrainedToSize: CGSizeMake(width, MAXFLOAT )
                            lineBreakMode: UILineBreakModeWordWrap];
    
    return labelSize;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

@end
