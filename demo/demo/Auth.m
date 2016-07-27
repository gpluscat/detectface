//
//  Auth.m
//  YoutuYunDemo
//
//  Created by Patrick Yang on 15/9/15.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "Auth.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#import "NSData+Base64.h"

@implementation Auth

+ (NSString *)appSignWithAppId:(NSString *)appId withSecretId:(NSString *)secretId withSecretKey:(NSString *)secretKey {
    unsigned int now = (int)[[NSDate date] timeIntervalSince1970];
    unsigned int rdm = (int)random() % 1000000000;
    NSString *origin = [NSString stringWithFormat:@"a=%@&k=%@&e=%u&t=%u&r=%d&u=%zd&f=%@", appId, secretId, 1000000 + now, now, rdm, 1831028945, @""];
    NSData *data = [self hmacsha1:origin secret:secretKey];
    NSMutableData *all = [NSMutableData dataWithData:data];
    [all appendBytes:origin.UTF8String length:origin.length];
    NSString *base64 = [all base64String];
    return base64;
}

+ (NSData *)hmacsha1:(NSString *)data secret:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return HMAC;
}

@end
