//
//  THMultiSegmentProgressView.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/22.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THMultiSegmentProgressView : UIView

@property (nonatomic,strong) NSMutableArray<NSValue *> *progerssSegments;
@property (nonatomic,assign) NSUInteger totalValue;
@property (nonatomic,strong) UIColor *progressColor;
@property (nonatomic,strong) NSValue *currentProgressValue;
@property (nonatomic,assign) CGFloat sliderThumbProgress;
@property (nonatomic,copy) void(^valueChangeCallback)(CGFloat value);
- (void)updateProgress;
- (void)clear;
@end
