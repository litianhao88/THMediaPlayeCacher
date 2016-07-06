//
//  THAutoColorLabel.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THAutoColorLabel.h"

@interface THAutoColorLabel  ()

@end

@implementation THAutoColorLabel

- (void)setProgress:(CGFloat)progress
{
    _progress = progress ;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self.progressColor set];
    rect.size.width *= self.progress ;
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}


@end
