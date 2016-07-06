//
//  THMusicModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "THModel.h"

@class THSingerModel ;
@class THLrcModel ;

@interface THMusicModel : THModel <NSCoding>

@property (nonatomic,copy) NSString *songname;
@property (nonatomic,copy) NSString *singername;
@property (nonatomic,assign) NSUInteger m4afilesize;
@property (nonatomic,copy) NSString *HASH;
@property (nonatomic,assign) BOOL isnew;
@property (nonatomic,copy) NSString *filename;
@property (nonatomic,copy) NSString *extname;
@property (nonatomic,assign) NSUInteger duration;
@property (nonatomic,copy) NSString *album_name;

@property (nonatomic,copy) NSString *playUrlString;

@property (nonatomic,strong) THSingerModel *singer;
@property (nonatomic,strong) THLrcModel *lrc;

@end
