//
//  THLrcDisplayView.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THlrcViewModel.h"

@interface THLrcDisplayView : UITableView


@property (nonatomic,strong) THlrcViewModel *viewModel;

- (void)updateCurrentTime:(CGFloat)currentTime;

@end
