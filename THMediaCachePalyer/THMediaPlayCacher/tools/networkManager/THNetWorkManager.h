//
//  THNetWorkManager.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworkReachabilityManager.h"

@interface THNetWorkManager : NSObject

+ (void)startObservReachability;

+ (NSDictionary<NSNumber *, NSString *> *)reachabilityNotificationNamesForAllStatus;

+ (AFNetworkReachabilityStatus)currentNetworkReachabilityStatus;

+ (void)GET:(NSString *)urlstring parameter:(NSDictionary *)parameter requestConfigs:(NSDictionary *)requestConfigs completion:(void(^)(NSData *data, NSURLResponse * response, NSError * error))completion ;

+ (void)POST:(NSString *)urlstring parameter:(NSDictionary *)parameter requestConfigs:(NSDictionary *)requestConfigs  completion:(void(^)(NSData *data, NSURLResponse * response, NSError * error))completion ;

+ (void)searchSingerInfoWithName:(NSString *)singerName respondRange:(NSRange)respondRange  completion:(void(^)(NSData *data, NSURLResponse * response, NSError * error))completion ;
+ (void)searchMusicAddressWithMusicHash:(NSString *)musicHash respondRange:(NSRange)respondRange  completion:(void(^)(NSData *data, NSURLResponse * response, NSError * error))completion ;
+ (void)searchMusicsWithName:(NSString *)musicName respondRange:(NSRange)respondRange  completion:(void(^)(NSData *data, NSURLResponse * response, NSError * error))completion ;
+ (void)searchMusicLrcWithMusicName:(NSString *)musicName musicHash:(NSString *)musicHash time:(NSUInteger)time respondRange:(NSRange)respondRange completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion;

+ (void)loadVideoByPage:(NSInteger)page completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion ;

@end
