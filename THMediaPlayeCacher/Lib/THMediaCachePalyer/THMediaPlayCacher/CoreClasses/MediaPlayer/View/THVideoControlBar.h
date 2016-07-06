//
//  THVideoControlBar.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THVideoControlBar : UIView

@property (nonatomic,copy) void(^playBtnClkCallback)(BOOL shouldPlay);
@property (nonatomic,assign ) BOOL playing;
@property (nonatomic,copy) void(^seekToTimeCallBack)(NSTimeInterval time);
@property (nonatomic,assign) NSUInteger blockHiddenSourceCount;

- (void)configProgressBarWithTotalLength:(NSUInteger)totalLength ranges:(NSMutableArray<NSValue *> *)ranges;
- (void)configTotalValue:(CGFloat)totalValue;
- (void)updateCurrentProgress:(NSValue *)progressRangeValue ;

- (void)clearProgress;
- (void)setTotalTime:(NSTimeInterval)totalTime;
- (void)setCurrentTime:(NSTimeInterval)currentTime;
- (void)displayBar;

@end
