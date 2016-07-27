//
//  FlySpeech.h
//  demo
//
//  Created by qing on 16/7/22.
//  Copyright © 2016年 qing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FlySpeech : NSObject
@property (nonatomic, assign) BOOL isHasView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, copy) void (^success)(NSString *result);
@property (nonatomic, copy) void (^failure)(void);
+ (FlySpeech *)sharedInstance;
+ (void)createUtility;

- (void)startListening;
- (void)stopListening;
- (void)cancel;

@end
