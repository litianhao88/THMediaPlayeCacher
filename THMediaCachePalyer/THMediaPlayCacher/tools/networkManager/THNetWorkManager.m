//
//  THNetWorkManager.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THNetWorkManager.h"

#import "AFHTTPSessionManager.h"
#import "AFNetworkReachabilityManager.h"
#import "AFURLSessionManager.h"

static NSString *const baisiBaseUrl = @"http://route.showapi.com/255-1";
static NSString *const baisiMiyao  = @"be209ff0d2a5403095edd3c5ad148bd4";
static NSString *const baisiAppid = @"15999";
typedef NS_ENUM(NSInteger , THNetWorkManagerHTTPMethod)
{
    THNetWorkManagerHTTPMethodHeader,
    THNetWorkManagerHTTPMethodGet,
    THNetWorkManagerHTTPMethodPost
};

@interface THNetWorkManager ()


@property (nonatomic,strong) AFURLSessionManager *afURLSessionManager;

@end

@implementation THNetWorkManager


static THNetWorkManager *manager = nil ;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init] ;
    });
    return manager ;
}

+ (AFNetworkReachabilityStatus)currentNetworkReachabilityStatus
{
    AFNetworkReachabilityManager *rechablityManager =    [AFNetworkReachabilityManager sharedManager] ;
    if (rechablityManager.isReachableViaWiFi)  return AFNetworkReachabilityStatusReachableViaWiFi ;
    if (rechablityManager.isReachableViaWWAN ) return AFNetworkReachabilityStatusReachableViaWWAN ;
    if( rechablityManager.isReachable == NO )  return AFNetworkReachabilityStatusNotReachable ;

    return AFNetworkReachabilityStatusUnknown ;
}


- (AFURLSessionManager *)afURLSessionManager
{
    if (!_afURLSessionManager) {
        _afURLSessionManager = [[AFURLSessionManager alloc] init];
    }
    return  _afURLSessionManager ;
}


+ (void)startObservReachability
{
    THNetWorkManager *manager = [self sharedManager];
    NSDictionary *dict =  [self reachabilityNotificationNamesForAllStatus] ;
    [manager.afURLSessionManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         [[NSNotificationCenter defaultCenter] postNotificationName:dict[@(status)] object:nil];
    }];
    [manager.afURLSessionManager.reachabilityManager startMonitoring];
}

+ (void)stopObservReachability
{
    THNetWorkManager *manager = [self sharedManager];

    [manager.afURLSessionManager.reachabilityManager stopMonitoring];
}


+ (void)sendRequestWithUrlString:(NSString *)urlstring parameter:(NSDictionary *)parameter requestConfigs:(NSDictionary *)requestConfigs completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion httpMethod:(THNetWorkManagerHTTPMethod)method
{
    THNetWorkManager *manager = [self sharedManager];
    if (parameter.count) {
        __block NSString  *tempString = [urlstring stringByAppendingString:@"?"] ;
        [parameter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@"%@=%@" , key , obj]];
            tempString = [tempString stringByAppendingString:@"&"];
        }];
        urlstring = tempString.copy;
        urlstring = [urlstring substringToIndex:urlstring.length-1];
    }

    urlstring = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    NSURL *resultUrl = [NSURL URLWithString:urlstring];
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:resultUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    switch (method) {
        case THNetWorkManagerHTTPMethodPost:
            [requestM setHTTPMethod:@"POST"];
            break;
        case THNetWorkManagerHTTPMethodHeader:
            [requestM setHTTPMethod:@"HEAD"];
            break;
        default:
            break;
    }
    
    if (requestConfigs.count) {
        [requestConfigs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                [requestM addValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible =  YES;
    [[manager.afURLSessionManager.session dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible =  NO;
        if (completion) {
            completion(data , response , error);
        }
    }] resume];

}

+ (void)GET:(NSString *)urlstring parameter:(NSDictionary *)parameter requestConfigs:(NSDictionary *)requestConfigs completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion
{

    [self sendRequestWithUrlString:urlstring parameter:parameter requestConfigs:requestConfigs completion:completion httpMethod:THNetWorkManagerHTTPMethodGet];
}

+ (void)POST:(NSString *)urlstring parameter:(NSDictionary *)parameter requestConfigs:(NSDictionary *)requestConfigs completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    [self sendRequestWithUrlString:urlstring parameter:parameter requestConfigs:requestConfigs completion:completion httpMethod:THNetWorkManagerHTTPMethodPost];
}

+(void)searchSingerInfoWithName:(NSString *)singerName respondRange:(NSRange)respondRange completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    NSString *urlstring = APIBASEURL_SEARCHSINGER ;
    [self GET:urlstring parameter:@{@"name" : singerName} requestConfigs:@{@"apikey" : APIKEY} completion:completion];
}
+(void)searchMusicsWithName:(NSString *)musicName respondRange:(NSRange)respondRange completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    NSString *urlstring = APIBASEURL_SEARCHMUSIC ;
    [self GET:urlstring parameter:@{@"s" : musicName , @"page" : @(respondRange.location) ,@"size": @(respondRange.length)} requestConfigs:@{@"apikey" : APIKEY} completion:completion];
}
+ (void)searchMusicAddressWithMusicHash:(NSString *)musicHash respondRange:(NSRange)respondRange completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    NSString *urlstring = APIBASEURL_SEARCHMUSICADDRESS ;

    [self GET:urlstring parameter:@{@"hash" : musicHash} requestConfigs:@{@"apikey" : APIKEY} completion:completion];

    
}
+ (void)searchMusicLrcWithMusicName:(NSString *)musicName musicHash:(NSString *)musicHash time:(NSUInteger)time respondRange:(NSRange)respondRange completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    NSString *urlstring = APIBASEURL_SEARCHMUSICLRC ;
    [self GET:urlstring parameter:@{@"name" : musicName , @"hash" : musicHash , @"time" : @(time)} requestConfigs:@{@"apikey" : APIKEY} completion:completion];
}

+ (NSDictionary<NSNumber *, NSString *> *)reachabilityNotificationNamesForAllStatus
{

    return @{@(AFNetworkReachabilityStatusUnknown) : @"AFNetworkReachabilityStatusUnknownNotificationName",@(AFNetworkReachabilityStatusNotReachable):@"AFNetworkReachabilityStatusNotReachableNotificationName",
             @(AFNetworkReachabilityStatusReachableViaWWAN):
                 @"AFNetworkReachabilityStatusReachableViaWWANNotificationName",
             @(AFNetworkReachabilityStatusReachableViaWiFi):
                 @"AFNetworkReachabilityStatusReachableViaWiFiNotificationName"};
}

+ (void)loadVideoByPage:(NSInteger)page completion:(void (^)(NSData *, NSURLResponse *, NSError *))completion
{
    [self GET:baisiBaseUrl parameter:@{@"showapi_appid" : baisiAppid , @"showapi_sign" : baisiMiyao , @"type" : @"41"} requestConfigs:nil completion:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (completion) {
            completion(data , response , error);
        }
    }];
}

@end
