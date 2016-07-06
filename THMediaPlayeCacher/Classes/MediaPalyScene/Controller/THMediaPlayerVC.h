//
//  THMediaPlayerVC.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THMusicListModel , THMusicModel ;

@interface THMediaPlayerVC : UIViewController


@property (nonatomic,strong) THMusicModel *musicToDisplay;
- (void)screenOut;
- (void)screenIn;

@end
