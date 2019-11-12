//
//  HYAFNRequestUtil.h
//  OCADV
//
//  Created by MrChen on 2018/12/26.
//  Copyright © 2018 MrChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HYAFNRequestUtil : NSObject

+ (void)GET:(NSString *)urlString
    headers:(NSDictionary *)headers
 parameters:(NSDictionary *)parameters
   complete:(nullable void (^)(void))complete
    success:(void (^)(NSString *result))success
      faile:(void (^)(NSString *result,NSError *error))faile;

@end
