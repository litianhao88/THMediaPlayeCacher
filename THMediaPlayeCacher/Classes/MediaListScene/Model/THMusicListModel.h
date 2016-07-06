//
//  THMusicListModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THMusicModel ;

@interface THMusicListModel : NSObject <NSCoding>

@property (nonatomic,copy) NSString *listName;
@property (nonatomic,strong  ) NSMutableArray<THMusicModel *> *musics;

@end
