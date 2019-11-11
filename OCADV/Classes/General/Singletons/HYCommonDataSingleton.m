//
//  HYCommonDataSingleton.m
//  OCADV
//
//  Created by MrChen on 2019/3/8.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYCommonDataSingleton.h"

@implementation HYCommonDataSingleton

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static HYCommonDataSingleton *singleTon;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [super allocWithZone:zone];
    });
    
    return singleTon;
}

+ (instancetype)share
{
    return [[self alloc]init];
}

@end
