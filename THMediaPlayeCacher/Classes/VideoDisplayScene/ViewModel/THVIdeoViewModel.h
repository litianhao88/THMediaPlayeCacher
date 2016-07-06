//
//  THVIdeoViewModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THVideoModel.h"

@interface THVIdeoViewModel : NSObject

@property (nonatomic,strong) NSMutableArray<THVideoModel *> *videos;
@property (nonatomic,assign , readonly) NSInteger page;
- (void)loadVideoWithPage:(NSInteger)page completion:(void(^)())completion;

@end
