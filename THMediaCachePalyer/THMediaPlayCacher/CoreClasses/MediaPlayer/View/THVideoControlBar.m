//
//  THVideoControlBar.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVideoControlBar.h"
#import "NSObject+THRuntimeEx.h"
#import "THMultiSegmentProgressView.h"
#import "CommonMarco.pch"
@interface THVideoControlBar ()

@property (nonatomic,weak) UIButton *playOrPauseBtn;
@property (nonatomic,weak) THMultiSegmentProgressView *displayProcessBar;
@property (nonatomic,weak) UILabel *currentLabel;
@property (nonatomic,weak) UILabel *totalLabel;

/// 当前歌曲或视频总时长
@property (nonatomic,assign) NSTimeInterval totalTime;

@end

@implementation THVideoControlBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, -8);
        self.layer.shadowOpacity = 0.5 ;
        NSDictionary<NSString * , NSString *> *IvarDict = [self th_getIvarsKindOfClass:[UIView class]];
        [IvarDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull ivarName, NSString * _Nonnull ivarTypeName, BOOL * _Nonnull stop) {
            
            [self setValue:[self th_addsubview:NSClassFromString(ivarTypeName)] forKey:ivarName];
            
        }];
        __weak typeof(self) weakSelf = self ;
        [self.displayProcessBar setValueChangeCallback:^(CGFloat progress) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (strongSelf.seekToTimeCallBack) {
                strongSelf.seekToTimeCallBack(self.totalTime * progress);
            }
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        tap.numberOfTapsRequired = 1 ;
        [self addGestureRecognizer:tap];
        
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateSelected];
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
        [self.playOrPauseBtn addTarget:self action:@selector(playOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.displayProcessBar setProgressColor:kMainThemeBackgroundColor(1)];
        
        self.totalLabel.textColor =kMainThemeBackgroundColor(1);
        self.currentLabel.textColor = kMainThemeBackgroundColor(1);
        self.totalLabel.font = self.currentLabel.font = [UIFont systemFontOfSize:14];
        self.totalLabel.text = self.currentLabel.text = @"00 : 00" ;


    }
    return  self ;
}

- (void)playOrPauseBtn:(UIButton *)sender
{
    [self displayBar];
    sender.selected = !sender.selected ;
    if (self.playBtnClkCallback) {
        self.playBtnClkCallback(sender.selected);
    }
}

- (void)tapGes:(UITapGestureRecognizer *)tap
{
    [self displayBar];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat margin = 8 ;
    CGFloat labelWidth = 60 ;
      self.playOrPauseBtn.frame =  CGRectMake(margin, margin, self.myHeight - 2*margin , self.myHeight - 2 * margin);
    self.currentLabel.frame = CGRectMake(margin + self.playOrPauseBtn.myTailPoint.x  , margin, labelWidth, self.displayProcessBar.frame.size.height);

    self.displayProcessBar.frame =  CGRectMake(self.currentLabel.myTailPoint.x + margin, margin , self.bounds.size.width - 2*labelWidth - self.playOrPauseBtn.myWidth - 2 * margin, self.playOrPauseBtn.myHeight);
    self.totalLabel.frame = CGRectMake(self.displayProcessBar.frame.origin.x + self.displayProcessBar.frame.size.width + margin, self.displayProcessBar.frame.origin.y, self.currentLabel.frame.size.width, self.displayProcessBar.frame.size.height);
}

- (void)configProgressBarWithTotalLength:(NSUInteger)totalLength ranges:(NSMutableArray<NSValue *> *)ranges
{
    self.displayProcessBar.totalValue = totalLength ;
    self.displayProcessBar.progerssSegments = ranges ;
}

- (void)displayBar
{
    self.blockHiddenSourceCount ++ ;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)( 5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.blockHiddenSourceCount -- ;
            if(self.blockHiddenSourceCount == 0)
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.alpha = 1 ;
                }];
            }
        });
    }];
}

- (void)updateCurrentProgress:(NSValue *)progressRangeValue
{
    self.displayProcessBar.currentProgressValue = progressRangeValue ;
}

- (void)configTotalValue:(CGFloat)totalValue
{
    self.displayProcessBar.totalValue = totalValue ;
}
- (void)setTotalTime:(NSTimeInterval)totalTime
{
    _totalTime = totalTime ;
    self.totalLabel.text = [NSString th_stringWithTimeinterval:totalTime];
}


- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    if (self.displayProcessBar ) {
        [self.displayProcessBar setSliderThumbProgress:(CGFloat)currentTime/_totalTime];
    }
    self.currentLabel.text = [NSString th_stringWithTimeinterval:currentTime];
}

- (void)setPlaying:(BOOL)playing
{
    self.playOrPauseBtn.selected = playing ;
}
- (void)clearProgress
{
    [self.displayProcessBar clear];
}

@end
