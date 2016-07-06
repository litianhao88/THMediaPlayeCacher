//
//  THLrcModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THLrcModel.h"

#import "NSString+THLrcPareserEx.h"

@interface THLrcModel ()

@property (nonatomic,strong) NSMutableDictionary *p_lrcStringMap;
@property (nonatomic,strong) NSMutableArray *timeLineArrM;

@end

@implementation THLrcModel


- (NSMutableDictionary *)p_lrcStringMap
{
    if (!_p_lrcStringMap) {
        _p_lrcStringMap = [NSMutableDictionary dictionary];
    }
    return  _p_lrcStringMap ;
}

- (NSDictionary *)lrcStringMap
{
    return [_p_lrcStringMap copy];
}

- (NSArray *)lrcStrings
{
    return [self.p_lrcStringMap copy];
}

- (void)setContent:(NSString *)content
{
  NSDictionary *dict = [content getLrcContentAndTimeMap];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:dict.count];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull timeStr, NSString * _Nonnull lrcContent, BOOL * _Nonnull stop) {
        NSTimeInterval timeInterval =[timeStr timeInterval];
        [dictM setObject:lrcContent forKey:@(timeInterval)];
    }];
    self.timeLineArrM = dictM.allKeys.mutableCopy ;
 self.timeLineArrM =  [self.timeLineArrM sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber  *_Nonnull obj2) {
     
     if (obj1.integerValue < obj2.integerValue) {
         return NSOrderedAscending;
     }
     else if(obj1.integerValue > obj2.integerValue)
     {
         return NSOrderedDescending;
     }else
     {
         return NSOrderedSame;
     }
  }].mutableCopy;
    self.p_lrcStringMap = dictM ;
}
- (NSArray *)timeLineArr
{
    return self.timeLineArrM.copy;
}

- (NSMutableArray *)timeLineArrM
{
    if (!_timeLineArrM) {
        _timeLineArrM = [NSMutableArray array];
    }
    return  _timeLineArrM ;
}
@end
