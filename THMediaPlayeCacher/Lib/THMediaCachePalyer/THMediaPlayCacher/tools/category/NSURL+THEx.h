//
//  NSURL+THEx.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger , NSURL_THExPathMode)
{
    NSURL_THExPathModeDocumentDirectory,
    NSURL_THExPathModeCacheDirectory,
    NSURL_THExPathModeTempDirectory,
    NSURL_THExPathModeCustomDirectory
};

@interface NSURL (THEx)

- (instancetype)th_UrlByReplaceSchemeName:(NSString *)schemeName;
- (NSString *)th_cacheFilePathWithDirectoryMode:( NSURL_THExPathMode)directioryMode customDirectoryPath:(NSString *)customDirectoryPath extensionName:(NSString *) extensionName;

@end
