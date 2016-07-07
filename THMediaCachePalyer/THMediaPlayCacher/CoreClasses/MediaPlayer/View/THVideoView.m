//
//  THVideoView.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVideoView.h"

@interface THVideoView ()
@property (nonatomic,weak) UILabel *tipLbl;

@end

@implementation THVideoView

@dynamic player ;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        AVPlayerLayer *playerLayer = self.layer ;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect ;
        
        UILabel *tipLbl = [UILabel new];
        self.tipLbl = tipLbl ;
        [self addSubview:tipLbl];
        self.tipLbl.text = @"再按一次退出播放";
        self.tipLbl.textAlignment = NSTextAlignmentCenter;
        self.tipLbl.backgroundColor = kMainThemeBackgroundColor(1);
        self.tipLbl.textColor = kMainThemeColor(1);
        self.tipLbl.layer.cornerRadius = 8 ;
        self.tipLbl.clipsToBounds = YES ;
        
        self.tipLbl.hidden = YES ;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }
    return self;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden == NO) {
        self.tipLbl.hidden = YES ;
    }else
    {
        [self.controlBar clearProgress];
    }
}

- (void)setControlBar:(THVideoControlBar *)controlBar
{
    [_controlBar removeFromSuperview];
    _controlBar = controlBar ;
    controlBar.backgroundColor = kMainThemeColor(1);
    [self addSubview:controlBar];

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.controlBar.frame = CGRectMake(0, self.myHeight- 30, self.myWidth, 30);
    self.tipLbl.bounds = CGRectMake(0, 0, 150, 30);
    self.tipLbl.center = self.center ;
}

//设置支持的layer层
+(Class)layerClass{
    return [AVPlayerLayer class];
}

//获取player
-(AVPlayer *)player{
    return [(AVPlayerLayer*)[self layer] player];
}

//给layer添加player
-(void)setPlayer:(AVPlayer *)player{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.controlBar.frame,  [[touches anyObject] locationInView:self]))
    {
        [self.controlBar displayBar];
        return ;
    }
    if (self.tipLbl.hidden) {
        self.tipLbl.hidden = NO ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipLbl.hidden = YES ;
        });
    }else
    {
        [self removeFromSuperview];
        if (self.stopPlayCallBack) {
            self.stopPlayCallBack();
        }
    }
}

@end
