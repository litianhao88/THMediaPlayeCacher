//
//  THlrcViewModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "THMusicModel.h"
#import "THLrcModel.h"
@interface THlrcViewModel : NSObject

@property (nonatomic,copy) void(^timerCallback)(NSUInteger timesPerSeconds);
@property (nonatomic,copy) void(^lrcDownLoadCallBack_asyn)(THlrcViewModel *viewModel);

@property (nonatomic,strong) THMusicModel *musicModel;

- (NSString *)lrcContentAtTime:(NSTimeInterval)time;

@end
