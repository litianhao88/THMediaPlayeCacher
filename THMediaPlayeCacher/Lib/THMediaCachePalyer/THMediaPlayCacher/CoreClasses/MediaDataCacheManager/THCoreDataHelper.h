//
//  THCoreDataHelper.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MediaCacheMap ;

@interface THCoreDataHelper : NSObject

+ (instancetype)sharedCoreDataHelper;

+ (MediaCacheMap *)cacheMapWithMD5Key:(NSString *)urlMD5Key;
//+ (void)addCacheMapWithMD5Key:(NSString *)urlMD5Key;
+ (NSArray<MediaCacheMap *> *)allMediaCacheMaps;
//+ (MediaCacheMap *)cacheMapWithFilterInfo:(NSDictionary<NSString * , id > *)filterInfo;
+ (MediaCacheMap *)createMediaCacheMapWithUrlMD5Key:(NSString *)urlMD5Key;
+ (MediaCacheMap *)updateCacheMapWithMD5Key:(NSString *)urlMD5Key;
+ (void)saveWithError:(NSError **)error;
+ (void)clearAllCache;
@end

FOUNDATION_EXTERN NSString *const kTHMediaCacheMapEntityName ;

