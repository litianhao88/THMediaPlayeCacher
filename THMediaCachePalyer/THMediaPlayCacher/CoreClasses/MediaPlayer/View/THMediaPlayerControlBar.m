//
//  THMediaPlayerControlBar.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/21.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaPlayerControlBar.h"

#import "UIView+THEx.h"
#import "NSString+THEx.h"
#import "NSObject+THRuntimeEx.h"
#import "THMultiSegmentProgressView.h"

@interface THMediaPlayerControlBar ()

@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UIButton *playVCBtn;
@property (nonatomic,weak) UIButton *playOrPauseBtn;
@property (nonatomic,weak) UIButton *preBtn;
@property (nonatomic,weak) UIButton *nxtBtn;

@property (nonatomic,weak) THMultiSegmentProgressView *displayProcessBar;
@property (nonatomic,weak) UILabel *currentLabel;
@property (nonatomic,weak) UILabel *totalLabel;

/// 当前歌曲或视频总时长
@property (nonatomic,assign) NSTimeInterval totalTime;

@end

@implementation THMediaPlayerControlBar

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
        self.backgroundColor =  kMainThemeColor(1);

        [self settingSubViews];

    
            }

    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    [self.playVCBtn setTitleColor:kMainThemeBackgroundColor(1) forState:UIControlStateNormal];
    self.playVCBtn.titleLabel.numberOfLines = 0 ;
    self.playVCBtn.titleLabel.font = System_Font_InstanceOfUIFont(12 );
    
    [self.playVCBtn addTarget:self action:@selector(playVCBtnClk) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    tap.numberOfTapsRequired = 1 ;
    [self addGestureRecognizer:tap];
    __weak typeof(self) weakSelf = self ;
[self.displayProcessBar setValueChangeCallback:^(CGFloat progress) {
    __strong typeof(weakSelf) strongSelf = weakSelf ;
    if (strongSelf.seekToTimeCallBack) {
        strongSelf.seekToTimeCallBack(self.totalTime * progress);
    }
}];
    return self ;
}

- (void)playVCBtnClk
{
    if (self.controlBarClkCallback) {
        self.controlBarClkCallback();
    }
}

- (void)tapGes:(UITapGestureRecognizer *)tap
{
    [self displayBar];
}



- (void)settingSubViews
{
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_btn_pause_normal"] forState:UIControlStateSelected];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
        [self.playOrPauseBtn addTarget:self action:@selector(playOrPauseBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.nxtBtn setImage:[UIImage imageNamed:@"player_btn_next_normal"] forState:UIControlStateNormal];
    [self.preBtn setImage:[UIImage imageNamed:@"player_btn_pre_normal"] forState:UIControlStateNormal];
    [self.nxtBtn addTarget:self action:@selector(nxtBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.preBtn addTarget:self action:@selector(preBtn:) forControlEvents:UIControlEventTouchUpInside];



    [self.displayProcessBar setProgressColor:kMainThemeBackgroundColor(1)];
    
    self.totalLabel.textColor =kMainThemeBackgroundColor(1);
    self.currentLabel.textColor = kMainThemeBackgroundColor(1);
    self.totalLabel.font = self.currentLabel.font = [UIFont systemFontOfSize:14];
    self.totalLabel.text = self.currentLabel.text = @"00 : 00" ;
    }


- (void)playOrPauseBtn:(UIButton *)sender
{
    [self displayBar];
    sender.selected = !sender.selected ;
    if (self.playBtnClkCallback) {
        self.playBtnClkCallback(sender.selected);
    }
}
- (void)nxtBtn:(UIButton *)sender
{
    [self displayBar];
    if (self.nextBtnClk) {
        self.nextBtnClk();
    }
}
- (void)preBtn:(UIButton *)sender
{
    [self displayBar];
    if (self.preBtnClk) {
        self.preBtnClk();
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat margin = 8 ;
    CGFloat labelWidth = 60 ;
    self.displayProcessBar.frame =  CGRectMake(labelWidth, margin , self.bounds.size.width - 2*labelWidth, 20);
    self.currentLabel.frame = CGRectMake(margin , self.displayProcessBar.frame.origin.y, labelWidth, self.displayProcessBar.frame.size.height);
    self.totalLabel.frame = CGRectMake(self.displayProcessBar.frame.origin.x + self.displayProcessBar.frame.size.width + margin, self.displayProcessBar.frame.origin.y, self.currentLabel.frame.size.width, self.displayProcessBar.frame.size.height);

    
    CGFloat btnBlrderLength =  self.bounds.size.height - 3*margin - self.displayProcessBar.frame.size.height ;
    self.nxtBtn.frame = CGRectMake(self.myWidth - margin - btnBlrderLength , self.displayProcessBar.frame.origin.y + self.displayProcessBar.frame.size.height + margin, btnBlrderLength , btnBlrderLength );
    

  self.playOrPauseBtn.frame = CGRectMake( self.nxtBtn.myX - margin - btnBlrderLength  , self.displayProcessBar.frame.origin.y + self.displayProcessBar.frame.size.height + margin , btnBlrderLength , btnBlrderLength );
    
    self.preBtn.frame = CGRectMake(self.playOrPauseBtn.frame.origin.x - btnBlrderLength - margin , self.playOrPauseBtn.frame.origin.y , btnBlrderLength , btnBlrderLength);
      
    self.icon.frame = CGRectMake(margin, self.displayProcessBar.myTailPoint.y + margin, self.myHeight - 2*margin - self.displayProcessBar.myTailPoint.y,  self.myHeight - 2*margin - self.displayProcessBar.myTailPoint.y);
    self.playVCBtn.frame = CGRectMake(self.icon.myTailPoint.x +margin, self.icon.center.y - 25, self.preBtn.myX - 2*margin -self.icon.myTailPoint.x, 50);

    if (self.icon.clipsToBounds == NO) {
        self.icon.clipsToBounds = YES ;
        self.icon.layer.cornerRadius = self.icon.myWidth/2 ;
    }
}

- (void)setIconImage:(UIImage *)iconImage
{
    _iconImage = iconImage;
    self.icon.image = iconImage ;
}

- (void)setTitle:(NSString *)title
{
    _title = title ;
    [self.playVCBtn setTitle:title forState:UIControlStateNormal];
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

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];

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

- (void)animationWithTimeRequence:(CGFloat)timePerSec
{
    self.icon.transform = CGAffineTransformRotate(self.icon.transform, M_PI_4 * timePerSec/10);
}

- (void)endAnimation
{
    self.icon.transform = CGAffineTransformIdentity ;
}

@end
