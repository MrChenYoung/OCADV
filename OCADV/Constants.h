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
#define ColorMain [UIColor colorWithRed:0/255.0 green:150/255.0 blue:255/255.0 alpha:1]
#define ColorLightGray [UIColor colorWithRed:195.0/255.0 green:195.0/255.0 blue:195.0/255.0 alpha:1]

// 字体
#define FontNomal [UIFont systemFontOfSize:14]

// cell标题和描述定义
#define CELLTITLE @"title"
#define CELLDESCRIPTION @"description"
#define CONTROLLERNAME @"controllername"

// 服务端ip和端口号
#define SERVERIP @"10.226.104.241"
//#define SERVERIP @"192.168.0.103"
#define SERVERPORT 6969

#endif /* Constants_h */
