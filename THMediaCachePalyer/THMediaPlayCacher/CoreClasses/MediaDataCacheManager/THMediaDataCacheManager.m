//
//  THMediaDataCacheManager.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaDataCacheManager.h"

#import "NSString+THEx.h"
#import "NSURL+THEx.h"
#import "CommonMarco.pch"

#import "THCoreDataHelper.h"
#import "MediaCacheMap.h"


static NSString *const cacheMapArchiverKey = @"mediaDataCacheMap" ;


@implementation THMediaDataCacheManager


static NSString *const currentExtName = nil ;

+ (NSArray<MediaCacheMap *> *)allMediaCacheMap
{
    return [THCoreDataHelper allMediaCacheMaps] ;
}


+ (MediaCacheMap *)mediaCacheMapOfUrl:(NSURL *)url
{
    NSString *urlMD5Key = [url.absoluteString th_md5String] ;
    return [THCoreDataHelper cacheMapWithMD5Key:urlMD5Key];
}

+ (NSArray<NSValue *> *)rangesOfUrl:(NSURL *)url
{
    MediaCacheMap *map = [self mediaCacheMapOfUrl:url];
    return  [map.segFileMaps allRanges];
}

+ (NSString *)directoryPathOfUrl:(NSURL *)url
{
    NSString *MD5Key = [url.absoluteString th_md5String];
  return  [BasicCacheDirectotyPath stringByAppendingPathComponent:MD5Key];

}

+ (void)moveFileAtPath:(NSString *)sourcePath toDirectoryPathCaculateUsingUrl:(NSURL *)urlForDestDirectoryPath rangeInTotalFile:(NSRange)rangeInTotalFiles
{
    MediaCacheMap *map = [self mediaCacheMapOfUrl:urlForDestDirectoryPath];
    if (!map) {
       map = [THCoreDataHelper createMediaCacheMapWithUrlMD5Key:[urlForDestDirectoryPath.absoluteString th_md5String]];
    }else
    {
        map = [THCoreDataHelper updateCacheMapWithMD5Key:[urlForDestDirectoryPath.absoluteString th_md5String]];
    }
    if (map.extensionTypeName.length == 0)
    {
        map.extensionTypeName = currentExtName.copy;
        map.extensionTypeName = [currentExtName componentsSeparatedByString:@"/"].lastObject;
    }

     NSString *directoryPath =   [self directoryPathOfUrl:urlForDestDirectoryPath];
        BOOL isDirectory = NO ;
        BOOL isExist = [kTHFILEMANAGER_InstanceOfNSFileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] ;
        
        if (!isDirectory || !isExist)
        {
            NSError *error = nil ;
            [kTHFILEMANAGER_InstanceOfNSFileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error)
            {
                NSLog(@"%@" ,error);
                return ;
            }
        }
    
        NSString *fileName =[NSString stringWithFormat:@"%zd-%zd.%@", rangeInTotalFiles.location , rangeInTotalFiles.length + rangeInTotalFiles.location  -1 , [ map.extensionTypeName componentsSeparatedByString:@"/"].lastObject] ;
        if(map.segFileMaps == nil)
        {
            map.segFileMaps = [THSegFileMaps segFileMapsWithFileName:fileName range:rangeInTotalFiles];
        }else
        {
         NSDictionary *dict =   [map.segFileMaps addMapWithFileName:fileName range:rangeInTotalFiles];
            map.segFileMaps = [THSegFileMaps segFileMapsWithdict:dict];
        }
    NSError *error1= nil ;
    BOOL sussecc = NO ;
    
    
  sussecc =  [kTHFILEMANAGER_InstanceOfNSFileManager moveItemAtPath:sourcePath toPath:[directoryPath stringByAppendingPathComponent:fileName] error:&error1];
    if (error1) {
        NSLog(@"%@  %zd" ,error1    , sussecc);
        return ;
    }
    
    NSError *error = nil ;
    [THCoreDataHelper saveWithError:&error];
    if (error) {
        NSLog(@"%@" ,error);
        return ;
    }

    [self reStroreMapFileWithMap:map];
//    NSLog(@"%@" , map.segFileMaps.fileMap );
}


+ (void)reStroreMapFileWithMap:(MediaCacheMap *)map
{
    NSMutableDictionary *dict = [[map.segFileMaps fileMap] mutableCopy];
    if (dict == nil)  return ;
    
    NSMutableArray *ranges = [[dict allKeys] mutableCopy];
    
    [ranges sortUsingComparator:^NSComparisonResult(NSValue  *_Nonnull value1, NSValue  *_Nonnull value2) {
        NSRange range1 = value1.rangeValue ;
        NSRange range2 = value2.rangeValue ;
        if (range1.location < range2.location) {
            return NSOrderedAscending;
        }else if (range1.location > range2.location){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    
    NSUInteger index = 0 ;
    NSUInteger rangesCount = ranges.count ;
    while (ranges.count - 1 > index)
    {
        if( ! [self mergeRangeAtIndex1:index rangeAtIndex2:index + 1 ranges:ranges dict:dict map:map] )
              {
                  index ++ ;
              }
    }
    
    if (ranges.count != rangesCount) {
        map.segFileMaps = [THSegFileMaps segFileMapsWithdict:dict];
        NSError *error = nil ;
        [THCoreDataHelper saveWithError:&error];
        if (error) {
            NSLog(@"%@" ,error);
            return ;
        }
    }
}

+ (BOOL )mergeRangeAtIndex1:(NSInteger )index1 rangeAtIndex2:(NSInteger)index2 ranges:(NSMutableArray *)ranges dict:(NSMutableDictionary *)dict map:(MediaCacheMap *)map
{
    NSValue *rangeValue1 = ranges[index1];
    NSValue *rangeValue2 = ranges[index2];
    NSRange range1 = rangeValue1.rangeValue;
    NSRange range2 = rangeValue2.rangeValue ;
    NSString  *filePath1 = [map filePathWithFileName:dict[rangeValue1]];
    NSString  *filePath2 = [map filePathWithFileName:dict[rangeValue2]];

    if (range1.location == range2.location)
    {
                if (range1.length <=  range2.length)
                {
                        [kTHFILEMANAGER_InstanceOfNSFileManager removeItemAtPath:filePath1 error:NULL];
                        [dict removeObjectForKey:[NSValue valueWithRange:range1]];
                    [ranges removeObjectAtIndex:index1];
                }else
                {
                        [kTHFILEMANAGER_InstanceOfNSFileManager removeItemAtPath:filePath2 error:NULL];
                        [dict removeObjectForKey:[NSValue valueWithRange:range2]];
                    [ranges removeObjectAtIndex:index2];
                }
                return YES ;
    }else if (range1.location + range1.length >= range2.location)
    {
                if (range1.length + range1.location >= range2.location + range2.length ) {
                        [kTHFILEMANAGER_InstanceOfNSFileManager removeItemAtPath:filePath2 error:NULL];
                        [dict removeObjectForKey:[NSValue valueWithRange:range2]];
                    [ranges removeObjectAtIndex:index2];
                        return YES ;
                }else
                {
                        NSFileHandle *handle1 = [NSFileHandle fileHandleForWritingAtPath:filePath1];
                        NSFileHandle *handel2 = [NSFileHandle fileHandleForReadingAtPath:filePath2];
                        [handel2 seekToFileOffset:(range1.location + range1.length - range2.location )];
          
                
                        NSData *dataOf2 = [handel2 readDataToEndOfFile];
                        [handle1 seekToEndOfFile];
                        [handle1 writeData:dataOf2];
                        [handle1 closeFile];
                        [handel2 closeFile];
    
                        NSString *newFileName = [NSString stringWithFormat:@"%zd-%zd.%@" , range1.location, range2.location + range2.length-1, [map.extensionTypeName componentsSeparatedByString:@"/"].lastObject];
                        NSError *error = nil ;
                    NSString *newFilePath = [map filePathWithFileName:newFileName]  ;

                        [kTHFILEMANAGER_InstanceOfNSFileManager moveItemAtPath:filePath1 toPath:newFilePath error:&error];
                        if (error) {
                            NSLog(@"%@" ,error);
                        }
              
                        [kTHFILEMANAGER_InstanceOfNSFileManager removeItemAtPath:filePath2 error:NULL];
                    NSValue *newRangeValue = [NSValue valueWithRange:NSMakeRange(range1.location, range2.location + range2.length - range1.location)] ;
                        [dict setObject:newFileName forKey:newRangeValue];
                        [dict removeObjectForKey:[NSValue valueWithRange:range2]];
                        [dict removeObjectForKey:[NSValue valueWithRange:range1]];
                    ranges[index1] = newRangeValue;
                    [ranges removeObjectAtIndex:index2];
                    return  YES ;
                }
    }
    
    return NO ;
}

+ (NSString *)filePathOfUrl:(NSURL *)url inRange:(NSRange)range enough:(BOOL *)isEnough usefulRange:(NSRange *)usefulRange nextFileStartOffset:(NSUInteger *)nextFileStartOffset
{
    MediaCacheMap *map = [self mediaCacheMapOfUrl:url];
  __block  NSString *filePath = nil ;

    if (map) {
        NSMutableArray *ranges =   [map.segFileMaps.fileMap allKeys].mutableCopy;
       [ranges sortUsingComparator:^NSComparisonResult(NSValue  *_Nonnull value1, NSValue  *_Nonnull value2) {
            NSRange range1 = value1.rangeValue ;
            NSRange range2 = value2.rangeValue ;
            if (range1.location < range2.location) {
                return NSOrderedAscending;
            }else if (range1.location > range2.location){
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        __block BOOL hasData = NO ;
        [ranges enumerateObjectsUsingBlock:^(NSValue  *_Nonnull rangeV, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange innerRange = rangeV.rangeValue ;
 
            if ( !hasData && NSLocationInRange(range.location, innerRange))
            {
                hasData = YES ;
                *usefulRange  = NSMakeRange(range.location - innerRange.location, MIN(innerRange.length + innerRange.location - range.location  - 1, range.length ));
                filePath = [map filePathWithFileName:[map.segFileMaps.fileMap objectForKey:rangeV]];
                if (innerRange.length + innerRange.location >= range.length + range.location)
                {
                    *isEnough = YES ;
                }
            }else{
            if (NSLocationInRange(innerRange.location, range)) {
                *nextFileStartOffset = innerRange.location ;
                *stop = YES ;
            }
            }
        }];
      }
    return filePath;
}

+ (NSDictionary *)reserve_filePathOfUrl:(NSURL *)url inRange:(NSRange)range
{
    MediaCacheMap *map = [self mediaCacheMapOfUrl:url];
    NSMutableDictionary *pathMap = [NSMutableDictionary dictionary];

    if (map) {
        [map.segFileMaps.fileMap enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull rangeV, NSString * _Nonnull filName, BOOL * _Nonnull stop) {
            NSRange innerRange = rangeV.rangeValue ;
            BOOL containHeader = NSLocationInRange(innerRange.location, range) ;
            BOOL containTail  = NSLocationInRange(innerRange.location + innerRange.length - 1, range) ;
            NSRange usefulRange ;
            if (containHeader && containTail ) {
                usefulRange = NSMakeRange(0 , innerRange.length);
                NSString *filePath = [map filePathWithFileName:filName];
                [pathMap setObject:[NSValue valueWithRange:usefulRange] forKey:filePath];

            }else if (containHeader && !containTail)
            {
                usefulRange = NSMakeRange(0 , range.length + range.location  - innerRange.location );
                NSString *filePath = [map filePathWithFileName:filName];
                [pathMap setObject:[NSValue valueWithRange:usefulRange] forKey:filePath];

            }else if (!containHeader && containTail)
            {
                usefulRange = NSMakeRange( range.location - innerRange.location , innerRange.location + innerRange.length  - range.location);
                NSString *filePath = [map filePathWithFileName:filName];
                [pathMap setObject:[NSValue valueWithRange:usefulRange] forKey:filePath];

            }else if (!containTail && !containHeader && (NSLocationInRange(range.location, innerRange) && NSLocationInRange(range.location + range.length - 1, innerRange)))
                      {
                          usefulRange = NSMakeRange(range.location - innerRange.location, range.length);
                          NSString *filePath = [map filePathWithFileName:filName];
                          [pathMap setObject:[NSValue valueWithRange:usefulRange] forKey:filePath];
                      }
            }];
    }
    return pathMap.copy ;
}



+ (long long)totalLengthOfUrl:(NSURL *)url
{
    return  [self mediaCacheMapOfUrl:url].totalLength.integerValue ;
}

+ (NSString *)finishDownloadedFilePathWithUrl:(NSURL *)url
{
    NSString *urlMD5Key = [url.absoluteString th_md5String];
    MediaCacheMap *map = [THCoreDataHelper cacheMapWithMD5Key:urlMD5Key];
    
    NSUInteger length  =  map.totalLength.integerValue ;

    __block NSString *filePath = nil ;
    [map.segFileMaps.fileMap enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull rangeV, NSString * _Nonnull fileName, BOOL * _Nonnull stop) {
        NSRange range = rangeV.rangeValue ;
        if (range.location == 0 && range.length == length) {
            filePath = [map filePathWithFileName:fileName];
        }
    }];
    return filePath ;
}

+ (void)bingdingTotalLength:(long long)totalLength extensionTypeName:(NSString *)extensionTypeName toModelOfUrl:(NSURL *)url
{
 
    MediaCacheMap *map = [self mediaCacheMapOfUrl:url];
    if (!map) {
        map =[THCoreDataHelper createMediaCacheMapWithUrlMD5Key:[url.absoluteString th_md5String]];
    }
   
    map.totalLength = @(totalLength);
    map.extensionTypeName = extensionTypeName.length ? extensionTypeName.copy : currentExtName.copy ;
    
    NSError *error = nil ;
    [THCoreDataHelper saveWithError:&error];
}


+ (void)setCurrentExtName:(NSString *)extName
{
    extName = [extName copy];
}

@end
