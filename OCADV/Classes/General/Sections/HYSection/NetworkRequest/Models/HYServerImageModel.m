//
//  HYServerImageModel.m
//  OCADV
//
//  Created by MrChen on 2019/1/16.
//  Copyright © 2019 MrChen. All rights reserved.
//

#import "HYServerImageModel.h"

@implementation HYServerImageModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        // 图片id
        self.media_id = dic[@"media_id"];
        
        // 图片名字
        self.name = dic[@"name"];
        
        // 更新时间戳
        self.update_time = [dic[@"update_time"] doubleValue];
        
        // 图片url
        self.url = dic[@"url"];
    }
    
    return self;
}

+ (instancetype)imageModelWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}

@end
