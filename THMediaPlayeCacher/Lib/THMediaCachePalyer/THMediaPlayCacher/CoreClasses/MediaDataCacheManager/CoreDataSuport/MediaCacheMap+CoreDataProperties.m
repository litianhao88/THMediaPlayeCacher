//
//  MediaCacheMap+CoreDataProperties.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaCacheMap+CoreDataProperties.h"

@implementation MediaCacheMap (CoreDataProperties)

@dynamic urlMd5Key;
@dynamic lastVisitDate;
@dynamic lrcFilePath;
@dynamic extensionTypeName;
@dynamic headerInfo;
@dynamic totalLength;
@dynamic segFileMaps;


- (NSString *)filePathWithFileName:(NSString *)fileName
{
    return   [[BasicCacheDirectotyPath stringByAppendingPathComponent:self.urlMd5Key] stringByAppendingPathComponent:fileName] ;
}

@end
