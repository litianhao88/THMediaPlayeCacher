//
//  segFileMapsTransformer.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THSegFileMaps : NSValueTransformer <NSCoding>

@property (nonatomic,strong) NSDictionary<NSValue * , NSString *> *fileMap;

+ (instancetype)segFileMapsWithFileName:(NSString *)fileName range:(NSRange)range;
- (NSDictionary *)addMapWithFileName:(NSString *)fileName range:(NSRange)range;
- (void)removeMapContainFileName:(NSString *)fileName ;
- (NSDictionary *)removeMapKeyedRange:(NSRange)range ;
- (NSArray<NSValue *> *)allRanges;
+ (instancetype)segFileMapsWithdict:(NSDictionary *)dict;

@end
