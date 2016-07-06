//
//  NSString+MD5Ex.h
//  coreData_test
//
//  Created by litianhao on 16/6/19.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (THEx)

- (NSString *)th_md5String;
- (NSString *)th_stringByDeleteLiteralBoxOfOcString;
- (NSTimeInterval)th_timeIntervalValue;
+ (NSString *)th_stringWithTimeinterval:(NSTimeInterval )timeInterval;
+ (NSDictionary *)mimetypeDict;

@end
