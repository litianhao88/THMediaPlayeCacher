//
//  UIImage+pureColorImg.h
//  导航栏测试
//
//  Created by litianhao on 16/3/7.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (pureColorImg)

///获得 指定alpha值  指定颜色的 纯色图片
+(instancetype)pureColorImgWithColor:(UIColor *)color alpha:(CGFloat)alpha size:(CGSize)size;

@end
