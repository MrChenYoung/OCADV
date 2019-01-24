//
//  Constants.h
//  OCADV
//
//  Created by MrChen on 2018/11/29.
//  Copyright © 2018 MrChen. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

// 屏幕大小
#define ScBounds [UIScreen mainScreen].bounds
#define ScWidth ScBounds.size.width
#define ScHeight ScBounds.size.height

// 状态栏高度
#define KStatusBarH 20.0

// 导航栏高度
#define KNavigationBarH 44.0

#define AppDelegateInstance (AppDelegate *)[UIApplication sharedApplication].delegate

// 颜色
#define ColorWithRGBA(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define ColorWithRGB(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define ColorMain [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1]
#define ColorLightGray [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1]
#define ColorGrayBg [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1]
#define ColorDefaultText ColorWithRGB(51.0,51.0,51.0)
// 字体
#define FontNomal [UIFont systemFontOfSize:14]

// 常用宏
#define CELLTITLE @"title"
#define CELLDESCRIPTION @"description"
#define CONTROLLERNAME @"controllername"
#define KACCESSTOKENKEY @"accessToken"
// 从相册加载图片失败
#define KLOADIMAGECOMPLETE @"loadImageComplete"

// 微信公众号信息
// 微信公众号账号信息
#define AppId @"wx1edac1543aa52bc9"
#define AppSecret @"57c757a41f1f0ffc8c77af8eafb57fc3"

// 微信小程序账号信息
//#define AppId @"wxdda428dee0e87a3b"
//#define AppSecret @"f157a773b25bebc8f11b637b3d8cbf1f"

#endif /* Constants_h */
