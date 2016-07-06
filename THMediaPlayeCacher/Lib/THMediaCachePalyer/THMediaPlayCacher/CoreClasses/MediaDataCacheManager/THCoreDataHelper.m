//
//  THCoreDataHelper.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/26.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THCoreDataHelper.h"
#import "MediaCacheMap.h"

static NSString *const cacheMapArchiverKey = @"mediaDataCacheMap" ;
NSString *const kTHMediaCacheMapEntityName = @"MediaCacheMap";

@interface THCoreDataHelper ()

@property (nonatomic,strong) NSManagedObjectContext *managerObjedtContext;
@property (nonatomic,strong) NSManagedObjectModel *managedObjextModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation THCoreDataHelper

+ (NSArray<MediaCacheMap *> *)cacheMapWithPredicate:(NSPredicate *)predicate
{
    
    THCoreDataHelper *helper = [THCoreDataHelper sharedCoreDataHelper];
    NSFetchRequest *fetchReq = [NSFetchRequest fetchRequestWithEntityName:kTHMediaCacheMapEntityName];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"urlMd5Key" ascending:YES];
    fetchReq.sortDescriptors = @[sort];
    fetchReq.predicate = predicate ;
   NSArray *arr =   [helper.managerObjedtContext executeFetchRequest:fetchReq error:NULL];

    return arr ;
}
static MediaCacheMap *temp = nil ;
+ (MediaCacheMap *)updateCacheMapWithMD5Key:(NSString *)urlMD5Key
{
    THCoreDataHelper *helper =  [self sharedCoreDataHelper] ;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    [fetchReq setEntity:[NSEntityDescription entityForName:kTHMediaCacheMapEntityName inManagedObjectContext:helper.managerObjedtContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"urlMd5Key = %@" , urlMD5Key]];
    temp = [helper.managerObjedtContext executeFetchRequest:fetchReq error:nil].firstObject;
   return  temp;
}


+ (MediaCacheMap *)cacheMapWithMD5Key:(NSString *)urlMD5Key
{
    return [self cacheMapWithPredicate:[NSPredicate predicateWithFormat:@"urlMd5Key = %@" , urlMD5Key]].firstObject ;
}


+ (NSArray<MediaCacheMap *> *)allMediaCacheMaps
{
    return [self cacheMapWithPredicate:nil];
}


static THCoreDataHelper *singleTon = nil ;
+ (instancetype)sharedCoreDataHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[self alloc] init];

    });
    return singleTon;
}


- (NSManagedObjectContext *)managerObjedtContext
{
    if (!_managerObjedtContext) {
        _managerObjedtContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managerObjedtContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managerObjedtContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjextModel];
        NSError *error = nil ;
        if (![kTHFILEMANAGER_InstanceOfNSFileManager fileExistsAtPath:MediaDataCacheMapFilePath]) {
            [kTHFILEMANAGER_InstanceOfNSFileManager createDirectoryAtPath:[MediaDataCacheMapFilePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
            [kTHFILEMANAGER_InstanceOfNSFileManager createFileAtPath:MediaDataCacheMapFilePath contents:nil attributes:nil];
        }
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:MediaDataCacheMapFilePath] options:nil error:&error];
        if (error) {
            NSLog(@"%@" ,error);
            return  nil;
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjextModel
{
    if (!_managedObjextModel) {

        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"mediaCacheMap" withExtension:@"momd"];
        _managedObjextModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjextModel ;
}

+ (MediaCacheMap *)createMediaCacheMapWithUrlMD5Key:(NSString *)urlMD5Key
{
    THCoreDataHelper *helper = [self sharedCoreDataHelper];
    MediaCacheMap *map = [NSEntityDescription insertNewObjectForEntityForName:kTHMediaCacheMapEntityName inManagedObjectContext:helper.managerObjedtContext];
    map.urlMd5Key = urlMD5Key.copy ;
    return map;
}

+ (void)saveWithError:(NSError *__autoreleasing *)error
{
    [[[self sharedCoreDataHelper] managerObjedtContext] save:error];
}

+ (void)clearAllCache
{
    THCoreDataHelper *helper =  [self sharedCoreDataHelper] ;
    [[self allMediaCacheMaps] enumerateObjectsUsingBlock:^(MediaCacheMap * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [helper.managerObjedtContext deleteObject:obj];
    }];
    [helper.managerObjedtContext save:NULL];
}

@end
