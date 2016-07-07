//
//  UIView+THEx.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/21.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "UIView+THEx.h"

#ifndef SCREEN_BOUNDS
#define SCREEN_BOUNDS ([UIScreen mainScreen].bounds)
#endif

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#endif


#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#endif

@implementation UIView (THEx)

-(void)scaleWithFixedCenterToSize:(CGSize)size{
    CGRect frame = self.frame;
    CGPoint center = self.center;
    frame.size = size ;
    self.frame = frame;
    self.center = center ;
}

- (UIView *)th_addsubview:(Class)subViewClass
{
    UIView *subView = [[subViewClass alloc] init];
    NSAssert([subView isKindOfClass:[UIView class]], @"输入类型错误 %zd " , __LINE__);
    
    [self addSubview:subView];
    return subView ;
}


-(CGRect)myFrame{
    return self.frame;
}
-(void)setMyFrame:(CGRect)myFrame{
    self.frame = myFrame;
}

-(CGRect)myBounds{
    return self.bounds;
}

-(void)setMyBounds:(CGRect)myBounds{
    self.bounds = myBounds;
}

-(CGFloat)myX{
    return self.frame.origin.x;
}

-(void)setMyX:(CGFloat)myX{
    CGRect frame = self.frame ;
    frame.origin.x = myX;
    self.frame = frame;
}

-(CGFloat)myY{
    return self.frame.origin.y;
}

-(void)setMyY:(CGFloat)myY{
    CGRect frame = self.frame ;
    frame.origin.y = myY;
    self.frame = frame;
}

-(CGFloat)myWidth{
    return self.frame.size.width;
}

-(void)setMyWidth:(CGFloat)myWidth{
    CGRect frame = self.frame;
    frame.size.width = myWidth;
    self.frame = frame;
}

-(CGFloat)myHeight{
    return self.frame.size.height;
}

-(void)setMyHeight:(CGFloat)myHeight{
    CGRect frame = self.frame;
    frame.size.height = myHeight;
    self.frame = frame;
}

-(CGPoint)myCenter{
    return self.center;
}

-(void)setMyCenter:(CGPoint)myCenter{
    CGPoint p = self.center;
    p.x = myCenter.x;
    p.y = myCenter.y;
    self.center = p;
}

-(CGFloat)myCenterX{
    return self.center.x;
}

-(void)setMyCenterX:(CGFloat)myCenterX{
    CGPoint p = self.center;
    p.x = myCenterX;
    self.center = p;
}

-(CGFloat)myCenterY{
    return self.center.y;
}

-(void)setMyCenterY:(CGFloat)myCenterY{
    CGPoint p = self.center;
    p.y = myCenterY;
    self.center = p;
}

-(CGPoint)myTailPoint{
    CGPoint p = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
    return p;
}

-(CGSize)mySize{
    return self.frame.size;
}
-(void)setMySize:(CGSize)mySize{
    CGRect frame = self.frame;
    frame.size = mySize;
    self.frame = frame;
}


+ (CGPoint)getLeftTopCornerPointWithFrame:(CGRect)frame
{
    return CGPointMake(frame.origin.x, frame.origin.y);
}

+ (CGPoint)getLeftBottomCornerPointWithFrame:(CGRect)frame
{
    CGFloat originX = frame.origin.x;
    CGFloat originY = frame.origin.y ;
    CGFloat H = frame.size.height;
    return CGPointMake(originX, originY + H);
}

+ (CGPoint)getRightTopCornerPointWithFrame:(CGRect)frame
{
    CGFloat originX = frame.origin.x;
    CGFloat originY = frame.origin.y ;
    CGFloat W = frame.size.width;
    
    return CGPointMake( originX + W, originY);
}

+ (CGPoint)getRightBottomCornerPointWithFrame:(CGRect)frame
{
    CGFloat originX = frame.origin.x;
    CGFloat originY = frame.origin.y ;
    CGFloat W = frame.size.width;
    CGFloat H = frame.size.height;
    return CGPointMake(  originX + W, originY + H);
}

- (void)shakeAnimationWithRotateAngle:(CGFloat)rotateAngle duration:(CGFloat)duration completionBlock:(void (^)(BOOL))completionBlock
{
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformMakeRotation(rotateAngle);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeRotation(-rotateAngle);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration/2 animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock(finished);
                }
            }];
        }];
    }];
    
}

- (void)th_setShaowWithOffset:(CGSize)offSet
{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = offSet;
    self.layer.shadowOpacity = 0.6 ;
}

@end
