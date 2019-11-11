//
//  RACView.h
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYRACView : UIView

// 信号提供者，可以充当信号，发送信号
@property (nonatomic, strong) RACSubject *racSubject;

@end

NS_ASSUME_NONNULL_END
