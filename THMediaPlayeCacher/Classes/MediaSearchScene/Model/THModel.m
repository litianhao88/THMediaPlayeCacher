//
//  THModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THModel.h"

@interface THModel ()

@end

@implementation THModel
{
    NSMutableDictionary *_transforDict ;
}
+ (instancetype)musicModelWithDict:(NSDictionary *)dict
{
    return  [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return  self ;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [_transforDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull transforKey, NSString  *_Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:transforKey]) {
            [self setValue:value forKey:obj];
        }
    }];
}

- (NSMutableDictionary *)transforDict
{
    if (!_transforDict) {
        _transforDict = [NSMutableDictionary dictionary];
    }
    return _transforDict ;
}

- (void)setTransforDict:(NSMutableDictionary *)transforDict
{
    _transforDict = [transforDict mutableCopy];
}

@end
