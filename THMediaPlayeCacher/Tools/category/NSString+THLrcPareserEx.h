//
//  NSString+THLrcPareserEx.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (THLrcPareserEx)

- (NSDictionary *)getLrcContentAndTimeMap;
- (NSTimeInterval)timeInterval;
@end
