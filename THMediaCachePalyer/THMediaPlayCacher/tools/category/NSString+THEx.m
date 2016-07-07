//
//  NSString+MD5Ex.m
//  coreData_test
//
//  Created by litianhao on 16/6/19.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "NSString+THEx.h"

#import <CommonCrypto/CommonDigest.h>


@implementation NSString (THEx)

- (NSString *)th_md5String
{
        const char *cStr = [self UTF8String];
        
        unsigned char result[16];
        
        CC_MD5( cStr, strlen(cStr), result );
        return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                 result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                 result[12], result[13], result[14], result[15]
                ];
}

- (NSString *)th_stringByDeleteLiteralBoxOfOcString
{
    if ([self hasPrefix:@"@\""] || [self hasSuffix:@"\""]) {
        NSRange startRange = [self rangeOfString:@"@\""];
        NSRange endRange = [self rangeOfString:@"\"" options:NSBackwardsSearch];
        return  [self substringWithRange:NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length)];
    }
    return self ;
}

- (NSTimeInterval)th_timeIntervalValue
{
    NSArray *arr = [self componentsSeparatedByString:@":"] ;
  __block  NSTimeInterval totalSeconds = 0 ;
    [arr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString  *_Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSInteger basicSeconds = pow( 60 , arr.count - idx - 1) ;
        totalSeconds += basicSeconds * string.integerValue ;
    }];
    return totalSeconds ;
}


+ (NSString *)th_stringWithTimeinterval:(NSTimeInterval)timeInterval
{
    NSUInteger timeValue = (NSUInteger)timeInterval ;
    if (timeValue > 3600) {
        NSUInteger hours = timeValue/3600 ;
        NSUInteger minutes = (timeValue%3600)/60 ;
        NSUInteger seconds = timeValue%60 ;
        return [NSString stringWithFormat:@"%02zd : %02zd : %02zd" , hours , minutes , seconds];
    }else if (timeValue > 60){
    NSUInteger minutes = timeValue/60 ;
    NSUInteger seconds = timeValue%60 ;
    return [NSString stringWithFormat:@"%02zd : %02zd" , minutes , seconds];
    }
    
    return [NSString stringWithFormat:@"00 : %02zd" , timeValue];
}
+ (NSDictionary *)mimetypeDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MimeTypeTab.txt" ofType:nil] encoding:NSUTF8StringEncoding error:nil];

    NSArray *arr =  [str componentsSeparatedByString:@"\n"];
    [arr enumerateObjectsUsingBlock:^(NSString  *_Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *arr = [str componentsSeparatedByString:@" "] ;
        [dict setObject:arr.firstObject forKey:arr.lastObject];
    }];
    [dict writeToFile:@"/Users/litianhao/Desktop/mimeTypeTable.plist" atomically:YES];
    return nil ;
}

@end
