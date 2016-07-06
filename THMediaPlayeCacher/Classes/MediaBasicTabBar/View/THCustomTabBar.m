//
//  THCustomTabBar.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/25.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THCustomTabBar.h"
#import "NSObject+THRuntimeEx.h"
#import "CommonMarco.pch"
#import "THCoreDataHelper.h"
#import "MBProgressHUD+Show.h"

@interface THCustomTabBar ()

@property (nonatomic,strong) NSArray  *btnTitles;
@property (nonatomic,strong) NSArray *btns;
@property (nonatomic,weak) UIButton *qinghuancunBtn;
@end
@implementation THCustomTabBar

- (void)qinghuancunClk
{
    
    [kTHFILEMANAGER_InstanceOfNSFileManager removeItemAtPath:BasicCacheDirectotyPath error:NULL];
    [THCoreDataHelper clearAllCache];
    [MBProgressHUD showSuccessWithText:@"成功清理缓存"];
}
- (instancetype)initWithBtnArr:(NSArray<NSDictionary *> *)btnArr frame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
     UIButton *huancunBtn =   (UIButton *)[self th_addsubview:[UIButton class]];
        self.qinghuancunBtn = huancunBtn ;
        [huancunBtn setTitle:@"清缓存" forState:UIControlStateNormal];
        huancunBtn.titleLabel.font = System_Font_InstanceOfUIFont(14);
        [huancunBtn addTarget:self action:@selector(qinghuancunClk) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = kMainThemeColor(1);
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_btnTitles.count];
        [btnArr enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton *btn = (UIButton *) [self th_addsubview:[UIButton class]];
            [btn setTitle:dict[@"title"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:dict[@"tabbarImg"]] forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [btn addTarget:self action:@selector(btnClk:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1+idx ;
            [arr addObject:btn];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            btn.adjustsImageWhenHighlighted = NO ;
        }];
        self.btns = arr.copy;
        [self th_setShaowWithOffset:CGSizeMake(0, 8)];
        [self.btns.firstObject setSelected:YES];
          }
    return  self ;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat const margin = 8 ;
    self.qinghuancunBtn.frame = CGRectMake(margin , margin + 20, 50, self.myHeight-2*margin - STATUEBAR_HEIGHT_CGFloat);
    CGFloat const width = (self.myWidth - (self.btns.count  )*margin - 10*margin)/self.btns.count;
    [self.btns enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setFrame:CGRectMake(idx *(width + margin) + margin * 5, margin + STATUEBAR_HEIGHT_CGFloat, width, self.myHeight-2*margin - STATUEBAR_HEIGHT_CGFloat)];
    }];
}
- (void)btnClk:(UIButton *)sender
{
    
    sender.selected = YES ;
    [self.btns enumerateObjectsUsingBlock:^(UIButton  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != sender) {
            obj.selected = NO ;
        }
    }];
    if (self.btnClkCallback) {
        self.btnClkCallback( sender.tag - 1);
    }
}

@end
