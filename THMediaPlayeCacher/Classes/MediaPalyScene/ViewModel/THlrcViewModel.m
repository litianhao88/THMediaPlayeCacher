//
//  THlrcViewModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THlrcViewModel.h"

#import "THNetWorkManager.h"
@implementation THlrcViewModel

- (NSString *)lrcContentAtTime:(NSTimeInterval)time
{
  __block NSTimeInterval pretime = -1  ;
    __block NSString *lrcContent = nil ;
    [self.musicModel.lrc.timeLineArr enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull timeNumber, NSUInteger idx, BOOL * _Nonnull stop) {
        if (time >= pretime && time <timeNumber.integerValue) {
            lrcContent = self.musicModel.lrc.lrcStringMap[@(pretime)];
            *stop = YES ;
        }
        pretime = timeNumber.integerValue;
    }];
    return lrcContent ;
}

- (void)setMusicModel:(THMusicModel *)musicModel
{
    _musicModel = musicModel ;
    
    if (musicModel.lrc == nil) {
        [UIApplication sharedApplication ].networkActivityIndicatorVisible = YES ;
        [THNetWorkManager searchMusicLrcWithMusicName:musicModel.songname musicHash:musicModel.HASH time:musicModel.duration respondRange:NSMakeRange(0, 1) completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            [UIApplication sharedApplication ].networkActivityIndicatorVisible = NO;
            if (error) {
                NSLog(@"%@" ,error);
                return ;
            }
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if ([dict.allKeys containsObject:@"data"]) {
                dict = dict[@"data"];
            }
            NSString *str = nil ;
            if (dict == nil  || [dict isKindOfClass:[NSNull class]]) {
                NSLog(@"请求失败");
                return ;
            }
            if ([dict.allKeys containsObject:@"content"]) {
                str  = dict[@"content"];
            }

            
            THLrcModel *model = [[THLrcModel alloc] init];
            [model setContent:str] ;
            musicModel.lrc = model ;
            if (self.lrcDownLoadCallBack_asyn) {
                self.lrcDownLoadCallBack_asyn(self);
            }
        }];
    }
}

- (void)timerSelector
{
    if (self.timerCallback) {
        self.timerCallback(60);
    }
}

@end
