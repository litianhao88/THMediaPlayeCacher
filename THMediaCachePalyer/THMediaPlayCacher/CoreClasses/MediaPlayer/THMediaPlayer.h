//
//  THMediaPlayer.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>


@class THMediaPlayerControlBar , AVPlayerLayer , AVPlayer ;

@interface THMediaPlayer : NSObject


@property (nonatomic,copy) void(^playEndedCallback) ();
@property (nonatomic,copy) void(^nextBtnClk) ();
@property (nonatomic,copy) void(^preBtnClk) ();
@property (nonatomic,copy) void(^updateProcessCallBack)(CGFloat currentPlayTime);
@property (nonatomic,copy) void(^shouldPlayNxtCallBack)();
@property (nonatomic,copy) void(^controlBarClkCallback) ();

+ (instancetype)defaultMediaPlayer;
+ (instancetype)PlayMediaAtUrl:(NSURL *)mediaUrl extName:(NSString *)extName showInView:(UIView *)view usingDefaultBar:(BOOL)usingDefaultBar isVideo:(BOOL)isVideo;
+ (void)setControlBarIcon:(UIImage *)icon;
+ (void) setTitle:(NSString *)title  controlBarClkCallback:(void(^)())controlBarClkCallback;

@end

FOUNDATION_EXTERN NSString *const kTHMediaPlayerPresentAlertControllerNotificationName ;
FOUNDATION_EXTERN NSString *const kTHMediaPlayerPresentAlertControllerKey ;

