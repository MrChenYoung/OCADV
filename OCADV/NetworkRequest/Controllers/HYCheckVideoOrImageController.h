//
//  HYPlayVideoController.h
//  OCADV
//
//  Created by MrChen on 2019/1/3.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HYCheckVideoOrImageController : UIViewController

// 动画开始的时候的位置和大小
@property (nonatomic, assign) CGRect fromReact;

// 是否是播放视频(不是播放视频就是查看图片,默认是查看图片)
@property (nonatomic, assign) BOOL checkVedio;

// 图片的网络路径
@property (nonatomic, copy) NSString *imageUrl;

// 界面消失以后回调
@property (nonatomic, copy) void (^dismissComplete)(BOOL deleteVideo);
@end

NS_ASSUME_NONNULL_END
