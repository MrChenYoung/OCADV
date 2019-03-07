/**
 *  @file
 *  @author 张凡
 *  @date 2016/3/25
 */
#import <UIKit/UIKit.h>

/**
 *  @class ZFToast
 *  @brief Toast弹窗控件
 *  @author 张凡
 *  @date 2016/3/25
 */

/**
 *  @使用方法
 *  [[ZFToast shareClient] popUpToastWithMessage:@"提示文字"];
 */

@interface HYToast : UIView

/// @brief 单例
+ (instancetype)shareToast;
/**
 * 从消息队列中取出消息逐条展示
 */
+ (void)toastWithMessage:(NSString *)message;

@end
