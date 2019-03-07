//
//  HYNetBaseView.h
//  OCADV
//
//  Created by MrChen on 2019/3/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYNetBaseView : UIView

/**
 * 创建模块标题label
 */
- (UILabel *)createModuleTitleLabelOrigin:(CGPoint)origin text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
