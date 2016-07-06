//
//  THMusicListManager.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THMusicListModel  , THMusicModel;

@interface THMusicListManager : NSObject

+ (void)loadMusicAddressWithHash:(NSString *)musicHash inMusicListNamed:(NSString *)musicListName;


+ (void)setCurrentOpretedList:(THMusicListModel *)listModel;
+ (void)synchronize;
+ (NSMutableDictionary<NSString * , THMusicListModel *> *)musicListDict;
+ (void)addMusicList:(THMusicListModel *)musicList toMusicListNamed:(NSString *)musicListName;
+ (THMusicListModel *)getMusicListNamed:(NSString *)musicListName;
+ (void)removeMusicListNamed:(NSString *)musicListName ;

+ (THMusicListModel *)createMusicListNamed:(NSString *)musicListName withMusics:(NSArray<THMusicModel *> *)musics;
+ (THMusicListModel *)curentOpretedList;


@end
