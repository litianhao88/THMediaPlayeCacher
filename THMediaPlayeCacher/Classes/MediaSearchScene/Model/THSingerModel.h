//
//  THSingerModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "THModel.h"

@interface THSingerModel : THModel <NSCoding>

@property (nonatomic,copy) NSString *image;
@property (nonatomic,copy) NSString *singername;


@end
