//
//  THVideoView.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import "THVideoControlBar.h"

@interface THVideoView : UIView

@property (nonatomic,weak)AVPlayer *player;
@property (nonatomic,weak)THVideoControlBar  *controlBar;

@property (nonatomic,copy) void(^stopPlayCallBack) ();
@end
