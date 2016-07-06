//
//  THMusicPlayController.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/25.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "THMediaPlayer.h"

@class THMusicModel ;

@interface THMusicPlayController : NSObject


+ (void)PlayMusic:(THMusicModel *)music showInView:(UIView *)view usingDefaultBar:(BOOL)usingDefaultBar;

+ (void)addNextBtnClkBlock:(void(^)(THMusicPlayController *playController))nextBtnClk ;
+ (void)addPreBtnClkBlock:(void(^)(THMusicPlayController *playController))preBtnClk ;
+ (void)addShouldPlayNxtBlock:(void(^)(THMusicPlayController *playController))shouldPlayNxtBlock ;
+ (void)setControlBarIcon:(UIImage *)icon;
+ (void)setTitle:(NSString *)title  controlBarClkCallback:(void(^)())controlBarClkCallback;
+ (THMusicModel *)currentPlayerMusic;

@end


FOUNDATION_EXTERN NSString *const THMusicPlayControllerNotificationName_UpdateProgress;
FOUNDATION_EXTERN NSString *const KTHUpdateProgressTimeKey ;

