//
//  UIImage+pureColorImg.m
//  导航栏测试
//
//  Created by litianhao on 16/3/7.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "UIImage+pureColorImg.h"

@implementation UIImage (pureColorImg)

+(instancetype)pureColorImgWithColor:(UIColor *)color alpha:(CGFloat)alpha size:(CGSize)size{
        UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
        [[color colorWithAlphaComponent:alpha] set];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        UIImage *targetImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        return targetImg;
}


@end
