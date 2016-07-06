//
//  THLrcModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THModel.h"

@interface THLrcModel : THModel

@property (nonatomic, strong , readonly) NSDictionary *lrcStringMap;
@property (nonatomic,strong , readonly) NSArray *timeLineArr;

- (void)setContent:(NSString *)content;

@end
