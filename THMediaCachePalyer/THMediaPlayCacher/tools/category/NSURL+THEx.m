//
//  NSURL+THEx.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "NSURL+THEx.h"
#import "NSString+THEx.h"

@implementation NSURL (THEx)

- (instancetype)th_UrlByReplaceSchemeName:(NSString *)schemeName
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:nil];
    urlComponents.scheme = schemeName ;
    return urlComponents.URL ;
}

- (NSString *)th_cacheFilePathWithDirectoryMode:(NSURL_THExPathMode)directioryMode customDirectoryPath:(NSString *)customDirectoryPath extensionName:(NSString *)extensionName
{
    NSString *directoryPath = nil ;
    switch (directioryMode) {
        case NSURL_THExPathModeDocumentDirectory:
            directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject ;
            break;
            case NSURL_THExPathModeCacheDirectory:
            directoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            break;
            case NSURL_THExPathModeTempDirectory:
            directoryPath = NSTemporaryDirectory();
            break;
            case NSURL_THExPathModeCustomDirectory:
             directoryPath = [customDirectoryPath copy];
            break ;
    }
    
   NSString *md5String  =  [self.absoluteString th_md5String];
    if (!extensionName.length) {
        return [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@" , md5String]];
    }
         return [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@" , md5String , extensionName]] ;
}

@end
