//
//  THModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface THModel : NSObject

+ (instancetype)musicModelWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

- (void)setTransforDict:(NSMutableDictionary *)transforDict;

@end
