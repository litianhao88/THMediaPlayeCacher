//
//  THMediaPlayerControlBar.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/21.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THMediaPlayerControlBar : UIView


@property (nonatomic,strong) UIImage *iconImage;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) void(^playBtnClkCallback)(BOOL shouldPlay);
@property (nonatomic,assign ) BOOL playing;
@property (nonatomic,copy) void(^seekToTimeCallBack)(NSTimeInterval time);
@property (nonatomic,copy) void(^nextBtnClk) ();
@property (nonatomic,copy) void(^preBtnClk) ();
@property (nonatomic,copy) void(^controlBarClkCallback)();
@property (nonatomic,assign) NSUInteger blockHiddenSourceCount;

- (void)configProgressBarWithTotalLength:(NSUInteger)totalLength ranges:(NSMutableArray<NSValue *> *)ranges;
- (void)configTotalValue:(CGFloat)totalValue;
- (void)updateCurrentProgress:(NSValue *)progressRangeValue ;


- (void)setTotalTime:(NSTimeInterval)totalTime;
- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (void)displayBar;

- (void)animationWithTimeRequence:(CGFloat)timePerSec;
- (void)endAnimation;

@end
