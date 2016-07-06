//
//  THMultiSegmentProgressView.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/22.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMultiSegmentProgressView.h"
#import "NSObject+THRuntimeEx.h"
#import "UIView+THEx.h"

@interface layerDelegate : NSObject

@property (nonatomic,strong) NSMutableArray *progressFrames;
@property (nonatomic,strong) UIColor *progressColor;

@end

@implementation layerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);
    // 设置颜色
    [self.progressColor set];
    [self.progressFrames enumerateObjectsUsingBlock:^(NSValue  *_Nonnull frameValue, NSUInteger idx, BOOL * _Nonnull stop) {
        // 图形混合模式
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:frameValue.CGRectValue];
        [rectPath fill];
    }];
    UIGraphicsPopContext() ;
}

@end

@interface THMultiSegmentProgressView ()

@property (nonatomic,strong) NSMutableArray *progressFrames;
@property (nonatomic,strong) CAShapeLayer *basicLayer;
@property (nonatomic,assign) CGRect currentProgressFrame;
@property (nonatomic,strong) layerDelegate *delegateLayer;
@property (nonatomic,weak) UIImageView *slider;
@property (nonatomic,assign) BOOL sliding;

@end

@implementation THMultiSegmentProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    
        self.layer.delegate = self ;
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"slider"]];
        self.slider = image ;
        [image sizeToFit];
        [self addSubview:image];
    }
    return self ;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);    
    if (layer == self.layer) {
        [self.progressColor set];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.currentProgressFrame];
        [path fill];
    }

    UIGraphicsPopContext();
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self dealFrames];
}

- (void)dealFrames
{
    
    [self.progressFrames removeAllObjects];
    CGRect frame = self.frame ;
    [self.progerssSegments enumerateObjectsUsingBlock:^(NSValue * _Nonnull progress, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeValue =  progress.rangeValue ;
        CGFloat startProgress = (CGFloat)rangeValue.location / _totalValue ;
        CGFloat endPreogerr = (CGFloat)(rangeValue.location + rangeValue.length) / _totalValue ;
        [self.progressFrames addObject:[NSValue valueWithCGRect:CGRectMake( frame.size.width * startProgress , self.myHeight/2 - 1 , frame.size.width * (endPreogerr - startProgress), 1)]];

    }];
    self.basicLayer.frame = self.bounds ;
    [self.basicLayer setNeedsDisplay];
}


- (NSMutableArray *)progressFrames
{
    if (!_progressFrames) {
        _progressFrames = [NSMutableArray array];
    }
    return  _progressFrames ;
}

- (UIColor *)progressColor
{
    if (!_progressColor) {
        _progressColor = [UIColor orangeColor];
    }
    return  _progressColor ;
}

- (void)setCurrentProgressValue:(NSValue *)currentProgressValue
{

    NSRange oldRange =  _currentProgressValue.rangeValue ;
    NSRange newRange = currentProgressValue.rangeValue ;
    
    if (oldRange.location != newRange.location) {
        if (_currentProgressValue) {
            [self.progerssSegments addObject:_currentProgressValue];
        }

    }
    _currentProgressValue = currentProgressValue ;

    [self updateProgress];
    [self dealFrames];
}

- (void)updateProgress
{
    NSRange range = self.currentProgressValue.rangeValue ;
    
    CGRect frame = self.bounds ;
    
    CGFloat startProgress = (CGFloat)range.location / _totalValue ;
    CGFloat endPreogerr = (CGFloat)(range.location + range.length) / _totalValue ;
    self.currentProgressFrame = CGRectMake( frame.size.width * startProgress , self.myHeight/2 - 1 , frame.size.width * (endPreogerr - startProgress), 2) ;

    [self.layer setNeedsDisplay];
}

- (CALayer *)basicLayer
{
    if (!_basicLayer) {
        CAShapeLayer *basicLayer  =  [CAShapeLayer layer] ;
        basicLayer.frame = self.bounds ;
        [self.layer addSublayer:basicLayer];
        _basicLayer = basicLayer ;
        layerDelegate *dele = [[layerDelegate alloc] init];
        self.delegateLayer = dele ;
        dele.progressColor = self.progressColor;
        dele.progressFrames = self.progressFrames ;
        basicLayer.delegate = dele ;
        [self bringSubviewToFront: self.slider];
    }
    return  _basicLayer ;
}



- (NSMutableArray<NSValue *> *)progerssSegments
{
    if (!_progerssSegments) {
        _progerssSegments = [NSMutableArray array];
    }
    return _progerssSegments ;
}

- (void)setTotalValue:(NSUInteger)totalValue
{
    if (totalValue) {
        _totalValue = totalValue ;
    }
}

- (void)setSliderThumbProgress:(CGFloat)sliderThumbProgress
{
    _sliderThumbProgress = sliderThumbProgress ;
    if (self.sliding == NO) {
        self.slider.frame = CGRectMake(sliderThumbProgress * self.myWidth, 0 ,  self.slider.myWidth, self.slider.myHeight);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

        self.sliding = YES ;

}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchP = [[touches anyObject] locationInView:touches.anyObject.view];

    if (self.sliding) {
        self.slider.myX =touchP.x ;
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint touchP = [[touches anyObject] locationInView:touches.anyObject.view];

    if (self.sliding) {
        if (self.valueChangeCallback) {
            self.valueChangeCallback(self.slider.myX / self.myWidth);
        }

        self.sliderThumbProgress = touchP.x / self.myWidth ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.sliding = NO ;
        });
    }
}
- (void)clear
{
    self.currentProgressFrame = CGRectZero;
    self.progressFrames = nil ;
    self.progerssSegments = nil ;
    [self.layer setNeedsDisplay];
    [self.basicLayer setNeedsDisplay];
}

@end
