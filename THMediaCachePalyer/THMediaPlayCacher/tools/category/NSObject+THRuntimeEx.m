//
//  NSObject+THRuntimeEx.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/21.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "NSObject+THRuntimeEx.h"
#import <objc/runtime.h>
#import "NSString+THEx.h"

@implementation NSObject (THRuntimeEx)

- (NSDictionary *)th_getAllIvars
{
    return [self th_getIvasUsingFilterBlock:^BOOL(NSString *ivarName, NSString *ivarTypeName) {
        return YES ;
    }];
}

- (NSDictionary *)th_getIvarsKindOfClass:(Class)class
{
    return [self th_getIvasUsingFilterBlock:^BOOL(NSString *ivarName, NSString *ivarTypeName) {
        if ([NSClassFromString(ivarTypeName) isSubclassOfClass:class]) {
            return YES ;
        }else
        {
            return NO ;
        }
    }];
}

- (NSDictionary *)th_getIvasUsingFilterBlock:(BOOL (^)(NSString *, NSString *))filterBlock
{
    unsigned int ivarCount ;
    NSMutableDictionary *resultDict = [NSMutableDictionary  dictionary];
    Ivar *ivars =  class_copyIvarList(self.class, &ivarCount);
    for (NSInteger i = 0; i < ivarCount; i ++) {
        Ivar tempIvar = ivars[i];
        const char *ivarName = ivar_getName(tempIvar);
        const char *ivarTypeName = ivar_getTypeEncoding(tempIvar);
        NSString *ivarNameOcStr = [NSString stringWithUTF8String:ivarName];
        NSString *ivarTypeNameOcStr = [[NSString stringWithUTF8String:ivarTypeName] th_stringByDeleteLiteralBoxOfOcString];
       
        if (filterBlock) {
            BOOL shouldAdd = filterBlock(ivarNameOcStr , ivarTypeNameOcStr) ;
           
            if (shouldAdd) {
                [resultDict setValue:ivarTypeNameOcStr forKey:ivarNameOcStr];
            }
       
        }
    }
    return [resultDict copy];
}



@end
