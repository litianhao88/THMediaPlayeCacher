//
//  THMusicListManager.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMusicListManager.h"

#import "THMusicListModel.h"
#import "THNetWorkManager.h"
#import "THMusicModel.h"

static NSString *const musicListFielPath = @"THMusic/musicList/myMusicList";
static NSMutableDictionary *musicListDict ;
static THMusicListModel *currentMusiListModel ;

@implementation THMusicListManager

+ (void)initialize
{
    NSString *AllmusicListFilePath = [kDocumentsPath_NSString stringByAppendingPathComponent:musicListFielPath] ;
    NSData *data = [NSData dataWithContentsOfFile:AllmusicListFilePath];
    if (data.length) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        musicListDict =  [unarchiver decodeObjectForKey:kTHMusicListKey];
        [unarchiver finishDecoding];
    }
    if (!musicListDict) {
        musicListDict = [NSMutableDictionary dictionary];
    }
}

+ (void)synchronize
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:musicListDict forKey:kTHMusicListKey];
    [archiver finishEncoding];

    
    NSString *filePath = [kDocumentsPath_NSString stringByAppendingPathComponent:musicListFielPath]  ;
   if( ![kTHFILEMANAGER_InstanceOfNSFileManager fileExistsAtPath:filePath])
   {
       [kTHFILEMANAGER_InstanceOfNSFileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
       [kTHFILEMANAGER_InstanceOfNSFileManager createFileAtPath:filePath contents:data attributes:nil];
   }else
   {
       [data writeToFile:filePath atomically:YES];
   }
}
+ (NSMutableDictionary<NSString *,THMusicListModel *> *)musicListDict
{
    return musicListDict;
}

+ (void)addMusicList:(THMusicListModel *)musicList toMusicListNamed:(NSString *)musicListName;
{
    if (!musicList || !musicListName.length ||
        ([[musicListDict allKeys] containsObject:musicListName] && [[musicListDict[musicListName] musics] isEqualToArray:musicList.musics]))
        return ;
    
        [musicListDict setObject:musicList forKey:musicListName];
}
+ (THMusicListModel *)getMusicListNamed:(NSString *)musicListName
{
    if (musicListName.length) {
        return [musicListDict objectForKey:musicListName];
    }
    return  nil ;
}

+ (void)removeMusicListNamed:(NSString *)musicListName
{
    if (musicListName.length) {
        [musicListDict removeObjectForKey:musicListName];
    }
}

+ (THMusicListModel *)createMusicListNamed:(NSString *)musicListName withMusics:(NSArray<THMusicModel *> *)musics
{
    THMusicListModel *model = [musicListDict objectForKey:musicListName];
    if (model) {
        [model.musics addObjectsFromArray:musics];
        return model ;
    }

     model = [[THMusicListModel alloc] init];
    model.musics = [musics mutableCopy];

    model.listName = musicListName ;
    [musicListDict setObject:model forKey:musicListName];
    return model ;
}

+ (void)setCurrentOpretedList:(THMusicListModel *)listModel
{
    currentMusiListModel = listModel ;
}

+ (THMusicListModel *)curentOpretedList
{
    return currentMusiListModel ;
}

+ (void)loadMusicAddressWithHash:(NSString *)musicHash inMusicListNamed:(NSString *)musicListName
{
    THMusicListModel *musicLister = musicListDict[musicListName];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES ;
    [THNetWorkManager searchMusicAddressWithMusicHash:musicHash respondRange:NSMakeRange(0, 1) completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
        if (error) {
            NSLog(@"%@" ,error);
            return ;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"data"];
   [musicLister.musics enumerateObjectsUsingBlock:^(THMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       if ([obj.HASH isEqualToString:musicHash]) {
           obj.playUrlString = dict[@"url"];
       }
   }];
    }];
}


@end
