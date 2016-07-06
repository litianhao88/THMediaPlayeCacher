//
//  NSString+THLrcPareserEx.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "NSString+THLrcPareserEx.h"

@implementation NSString (THLrcPareserEx)


- (NSTimeInterval)timeInterval
{
   NSArray *arr1=    [self componentsSeparatedByString:@":"];
    NSString *minus = arr1.firstObject ;
    NSArray *arr2 = [arr1.lastObject componentsSeparatedByString:@"."];
    NSString  *seconds = arr2.firstObject ;
    NSTimeInterval time = 60*minus.integerValue + seconds.integerValue;
    return time;
}
- (NSDictionary *)getLrcContentAndTimeMap
{

    NSArray *arr = [self componentsSeparatedByString:@"\n"];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:arr.count];
      [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          NSString *pattern = @"\\[\\S{1,}\\]";
          NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
          NSArray *arr1 = [rex matchesInString:obj options:1<<1 range:NSMakeRange(0, [obj length])];
          [arr1 enumerateObjectsUsingBlock:^(NSTextCheckingResult *_Nonnull result, NSUInteger idx, BOOL * _Nonnull stop) {
              NSRange range = result.range ;
              NSString *lrc = [obj substringFromIndex:range.location + range.length];
              NSString *timeLine = [obj substringWithRange:NSMakeRange(range.location +1, range.length - 2)];
              [dictM setObject:lrc forKey:timeLine];
          }];

    }];
    return  dictM ;
}

@end
