//
//  FlySpeech.m
//  demo
//
//  Created by qing on 16/7/22.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "FlySpeech.h"
#import <iflyMSC/iflyMSC.h>
#import <iflyMSC/IFlySpeechUtility.h>

#import "ISRDataHelper.h"

@interface FlySpeech()<IFlySpeechRecognizerDelegate, IFlyRecognizerViewDelegate>

@property (nonatomic, strong) NSString *pcmFilePath;//音频文件路径
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//不带界面的识别对象
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;//带界面的识别对象

@property (nonatomic, strong) NSMutableString *mutableResult;

@end


@implementation FlySpeech

+ (FlySpeech *)sharedInstance {
    static FlySpeech *instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[FlySpeech alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self){
        _mutableResult = [NSMutableString string];
    }
    return self;
}

+ (void)createUtility {
    [IFlySpeechUtility createUtility:@"appid=57919956"];
}

- (void)startListening {
    if(!_isHasView) {
        if(_iFlySpeechRecognizer == nil){
            [self initRecognizer];
        }
        [_iFlySpeechRecognizer cancel];
        [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        BOOL ret = [_iFlySpeechRecognizer startListening];
        if (ret) {
            NSLog(@">>>>>>>>>>ret %d", ret);
        }else{
            //可能是上次请求未结束，暂不支持多路并发
        }
    }
    else {
        if(_iflyRecognizerView == nil) {
            [self initRecognizer ];
        }
        
        //设置音频来源为麦克风
        [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
        
        //设置听写结果格式为json
        [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
        [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        
        [_iflyRecognizerView start];
    }
}

- (void)stopListening {
    if(!_isHasView) {
        if(_iFlySpeechRecognizer) {
            [_iFlySpeechRecognizer stopListening];
        }
    }
    else {
        if(_iflyRecognizerView) {
            [_iflyRecognizerView cancel];
        }
    }
    self.mutableResult = [NSMutableString string];
}

- (void)initRecognizer {
    if(!_isHasView) {
        //单例模式，无UI的实例
        if (_iFlySpeechRecognizer == nil) {
            _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
            [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            //设置听写模式
            [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        }
        _iFlySpeechRecognizer.delegate = self;
        
        if (_iFlySpeechRecognizer != nil) {
            //设置采样率，推荐使用16K
            [_iFlySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
            //设置是否返回标点符号
            [_iFlySpeechRecognizer setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
        }
    }
    else {
        //单例模式，UI的实例
        if (_iflyRecognizerView == nil) {
            //UI显示剧中
            _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:_view.center];
            
            [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
            
            //设置听写模式
            [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
            
        }
        _iflyRecognizerView.delegate = self;
        
        if (_iflyRecognizerView != nil) {
            
            [_iflyRecognizerView setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
            //设置是否返回标点符号
            [_iflyRecognizerView setParameter:@"1" forKey:[IFlySpeechConstant ASR_PTT]];
        }
    }
    
}

- (void)cancel {
    if(!_isHasView) {
        [_iFlySpeechRecognizer cancel]; //取消识别
        [_iFlySpeechRecognizer setDelegate:nil];
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        _iFlySpeechRecognizer = nil;
    }
    else {
        [_iflyRecognizerView cancel]; //取消识别
        [_iflyRecognizerView setDelegate:nil];
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        _iflyRecognizerView = nil;
        
        self.view = nil;
        self.isHasView = NO;
    }
    self.mutableResult = [NSMutableString string];
}

/*!
 *  识别结果回调
 *    在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，
 *  当errorCode没有错误时，表示此次会话正常结束；否则，表示此次会话有错误发生。特别的当调用
 *  `cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数
 *  之前如果重新调用了`startListenging`函数则会报错误。
 *
 *  @param errorCode 错误描述
 */
- (void) onError:(IFlySpeechError *) errorCode {
    NSLog(@">>>>>>>>>>errorCode code %d %@", [errorCode errorCode],[errorCode errorDesc]);
    if(errorCode.errorCode == 0){
        if(_mutableResult.length > 0) {
            // 成功
            if(self.success != nil){
                self.success(_mutableResult);
            }
        }
        else {
            // 失败
            if(self.failure != nil){
                self.failure();
            }
        }
    }
    else {
        // 失败
        if(self.failure != nil){
            self.failure();
        }
    }
}

/*!
 *  识别结果回调
 *    在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 *  使用results的示例如下：
 *  <pre><code>
 *  - (void) onResults:(NSArray *) results{
 *     NSMutableString *result = [[NSMutableString alloc] init];
 *     NSDictionary *dic = [results objectAtIndex:0];
 *     for (NSString *key in dic){
 *        [result appendFormat:@"%@",key];//合并结果
 *     }
 *   }
 *  </code></pre>
 *
 *  @param results  -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度。
 *  @param isLast   -[out] 是否最后一个结果
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    if(isLast) {
        
    }
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    
    NSString *resultFromJson = [ISRDataHelper stringFromJson:resultString];
    NSLog(@">>>>>>>>>>resultFromJson %@ %@", resultFromJson, resultString);
    [self.mutableResult appendString:resultFromJson];
}

/*!
 *  回调返回识别结果
 *
 *  @param resultArray 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度
 *  @param isLast      -[out] 是否最后一个结果
 */
- (void)onResult:(NSArray *)resultArray isLast:(BOOL) isLast {
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    NSLog(@">>>>>>>>>>result %@", result);
    [self.mutableResult appendString:result];
}


@end
