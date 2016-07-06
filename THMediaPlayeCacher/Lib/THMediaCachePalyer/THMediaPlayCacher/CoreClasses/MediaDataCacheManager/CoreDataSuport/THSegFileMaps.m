//
//  segFileMapsTransformer.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THSegFileMaps.h"

@interface THSegFileMaps ()

@end

@implementation THSegFileMaps

+ (instancetype)segFileMapsWithdict:(NSDictionary *)dict
{
    THSegFileMaps *model = [[THSegFileMaps alloc] init];

    model.fileMap = dict ;
    return model ;
}
+ (instancetype)segFileMapsWithFileName:(NSString *)fileName range:(NSRange)range
{
    THSegFileMaps *model = [[THSegFileMaps alloc] init];
    [model addMapWithFileName:fileName range:range];

    return model ;
}

- (NSDictionary *)addMapWithFileName:(NSString *)fileName range:(NSRange)range
{
    NSMutableDictionary *dict = self.fileMap.mutableCopy ;
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setObject:fileName forKey:[NSValue valueWithRange:range]];
    self.fileMap = dict.copy ;
    return dict.copy ;
}

- (void)removeMapContainFileName:(NSString *)fileName
{
//    [self.fileMap enumerateKeysAndObjectsUsingBlock:^(NSValue  *_Nonnull value, NSString  *_Nonnull myFileName, BOOL * _Nonnull stop) {
//        if ( [myFileName isEqualToString:fileName] ) {
//            [self.fileMap removeObjectForKey:value];
//            *stop = YES ;
//        }
//    }];
}

- (NSDictionary *)removeMapKeyedRange:(NSRange)range
{
    NSMutableDictionary *dict = self.fileMap.mutableCopy ;
    [dict removeObjectForKey:[NSValue valueWithRange:range]];
    return dict.copy;
//    [self.fileMap  removeObjectForKey:[NSValue valueWithRange:range]];
}

/**     允许转换    */
+ (BOOL)allowsReverseTransformation
{
    return YES;
}

/**     转换成什么类    */
+ (Class)transformedValueClass
{
    return [NSData class];
}

/**     返回转换后的对象    */
- (id)transformedValue:(id)value
{

    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

/**     重新生成原对象    */
- (id)reverseTransformedValue:(id)value
{  
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.fileMap = [aDecoder decodeObjectForKey:@"p_mapM"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fileMap forKey:@"p_mapM"];
}




- (NSArray<NSValue *> *)allRanges
{
    
    if(self.fileMap.count > 0)
    {
        return [self.fileMap allKeys];
    }
    return nil ;
}

@end
