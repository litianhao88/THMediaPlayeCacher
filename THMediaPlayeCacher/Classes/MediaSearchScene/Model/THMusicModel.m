//
//  THMusicModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMusicModel.h"

#import "THSingerModel.h"

@implementation THMusicModel



- (instancetype)initWithDict:(NSDictionary *)dict
{
   if( self =  [super init] )
   {
    self.transforDict = [@{@"hash" : @"HASH"} mutableCopy];
       [self setValuesForKeysWithDictionary:dict];
   }
    return self ;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.songname = [aDecoder decodeObjectForKey:@"songname"];
        self.singername = [aDecoder decodeObjectForKey:@"singername"];
        self.m4afilesize = [aDecoder decodeIntegerForKey:@"m4afilesize"];
        self.HASH = [aDecoder decodeObjectForKey:@"HASH"];
        self.isnew = [aDecoder decodeObjectForKey:@"isnew"];
        self.filename = [aDecoder decodeObjectForKey:@"filename"];
        self.extname = [aDecoder decodeObjectForKey:@"extname"];
        self.duration = [aDecoder decodeIntegerForKey:@"duration"];
        self.album_name = [aDecoder decodeObjectForKey:@"album_name"];
        self.playUrlString = [aDecoder decodeObjectForKey:@"playUrlString"];
        self.singer = [aDecoder decodeObjectForKey:@"singer"];
    }
    return self ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.songname forKey:@"songname"];
    [aCoder encodeObject:self.singername forKey:@"singername"];
    [aCoder encodeInteger:self.m4afilesize forKey:@"m4afilesize"];
    [aCoder encodeObject:self.HASH forKey:@"HASH"];
    [aCoder encodeObject:self.filename forKey:@"filename"];
    [aCoder encodeObject:self.extname forKey:@"extname"];
    [aCoder encodeInteger:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.album_name forKey:@"album_name"];
    [aCoder encodeObject:self.playUrlString forKey:@"playUrlString"];
    [aCoder encodeBool:self.isnew forKey:@"isnew"];
    [aCoder encodeObject:self.singer forKey:@"singer"];
}

- (THSingerModel *)singer
{
    if (!_singer) {
        _singer = [[THSingerModel alloc] init];
    }
    return  _singer;
}

@end
