//
//  MediaCacheMap+CoreDataProperties.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaCacheMap.h"

#import "THSegFileMaps.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaCacheMap (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *urlMd5Key;
@property (nullable, nonatomic, retain) NSNumber *lastVisitDate;

@property (nullable, nonatomic, retain) NSString *lrcFilePath;
@property (nullable, nonatomic, retain) NSString *extensionTypeName;
@property (nullable, nonatomic, retain) NSString *headerInfo;
@property (nullable, nonatomic, retain) NSNumber *totalLength;
@property (nullable, nonatomic, retain) THSegFileMaps *segFileMaps;

- (NSString *)filePathWithFileName:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
