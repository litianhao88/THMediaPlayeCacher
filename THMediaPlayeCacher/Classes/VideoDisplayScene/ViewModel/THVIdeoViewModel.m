//
//  THVIdeoViewModel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVIdeoViewModel.h"
#import "THNetWorkManager.h"

@implementation THVIdeoViewModel

- (void)loadVideoWithPage:(NSInteger)page completion:(void (^)())completion
{
  
    [THNetWorkManager loadVideoByPage:1 completion:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@" ,error);
            return ;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!dict) {
            return ;
        }
        if ([[dict allKeys] containsObject:@"showapi_res_body"]) {
            dict = dict[@"showapi_res_body"];
        }
        //pagebean
        if ([[dict allKeys] containsObject:@"pagebean"]) {
            dict = dict[@"pagebean"];
        }
        NSArray *arr ;
        if ([[dict allKeys] containsObject:@"contentlist"]) {
            arr = dict[@"contentlist"];
        }
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            THVideoModel *model = [THVideoModel videoWithDict:obj];
            [self.videos addObject:model];
        }];
        if (completion) {
            completion();
        }
    }];
}

- (NSMutableArray<THVideoModel *> *)videos
{
    if (!_videos) {
        _videos = [NSMutableArray array];
    }
    return  _videos;
}

- (NSInteger)page
{
    return self.videos.count / 20 + 1;
}

@end
