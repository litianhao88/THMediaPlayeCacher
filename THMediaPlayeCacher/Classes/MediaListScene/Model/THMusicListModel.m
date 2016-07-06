//
//  THMusicListModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMusicListModel.h"

@implementation THMusicListModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.musics = [[aDecoder decodeObjectForKey:@"musics"] mutableCopy];
        self.listName = [aDecoder decodeObjectForKey:@"listName"];
    }
    return self ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.musics forKey:@"musics"];
    [aCoder encodeObject:self.listName forKey:@"listName"];
}

- (NSMutableArray<THMusicModel *> *)musics
{
    if (!_musics) {
        _musics = [NSMutableArray array];
    }
    return _musics ;
}

@end
