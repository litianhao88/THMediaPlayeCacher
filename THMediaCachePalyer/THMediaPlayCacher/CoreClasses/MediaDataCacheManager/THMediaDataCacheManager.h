//
//  THMediaDataCacheManager.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  MediaCacheMap ,THCacheMapModel ;

@interface THMediaDataCacheManager : NSObject

+ (void)moveFileAtPath:(NSString *)sourcePath toDirectoryPathCaculateUsingUrl:(NSURL *)urlForDestDirectoryPath rangeInTotalFile:(NSRange)rangeInTotalFiles;
+ (void)bingdingTotalLength:(long long)totalLength extensionTypeName:(NSString *)extensionTypeName toModelOfUrl:(NSURL *)url;

+ (long long)totalLengthOfUrl:(NSURL *)url;
+ (NSArray<NSValue *> *)rangesOfUrl:(NSURL *)url;
+(NSString *)filePathOfUrl:(NSURL *)url inRange:(NSRange)range enough:(BOOL *)isEnough usefulRange:(NSRange *)usefulRange nextFileStartOffset:(NSUInteger *)nextFileStartOffset;

+ (NSArray<MediaCacheMap *> *)allMediaCacheMap;
+ (NSString *)finishDownloadedFilePathWithUrl:(NSURL *)url;
+ (MediaCacheMap *)mediaCacheMapOfUrl:(NSURL *)url;

+ (void)setCurrentExtName:(NSString *)extName;

@end
