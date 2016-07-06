//
//  THSingerModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THSingerModel.h"

#import "THNetWorkManager.h"

@implementation THSingerModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.image = [aDecoder decodeObjectForKey:@"image"];
        
    }
    return  self ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.image forKey:@"image"];
}

@end
