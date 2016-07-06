//
//  NSObject+THRuntimeEx.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/21.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (THRuntimeEx)

- (NSDictionary *)th_getAllIvars ;


- (NSDictionary *)th_getIvarsKindOfClass:(Class)class ;

- (NSDictionary *)th_getIvasUsingFilterBlock:(BOOL(^)(NSString *ivarName , NSString *ivarTypeName))filterBlock;

@end
