//
//  Auth.h
//  YoutuYunDemo
//
//  Created by Patrick Yang on 15/9/15.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Auth : NSObject

+ (NSString *)appSignWithAppId:(NSString *)appId withSecretId:(NSString *)secretId withSecretKey:(NSString *)secretKey;

@end
