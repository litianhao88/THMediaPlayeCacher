//
//  THVideoModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVideoModel.h"

@implementation THVideoModel

+ (instancetype)videoWithDict:(NSDictionary *)dict
{
    THVideoModel *model = [[self alloc] init];
    [model setValuesForKeysWithDictionary:dict];
    return model ;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([@"id" isEqualToString:key]) {
        [self setValue:value forKey:@"Id"];
    }
}

@end
