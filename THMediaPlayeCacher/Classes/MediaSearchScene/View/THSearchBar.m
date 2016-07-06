//
//  THSearchBar.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THSearchBar.h"
#import "NSObject+THRuntimeEx.h"


@interface THSearchBar () <UITextFieldDelegate>

@property (nonatomic,weak) UIButton  *searchBtn;
@property (nonatomic,weak) UITextField *searchInputTF;
@property (nonatomic,weak) UIButton *backBtn;

@end

@implementation THSearchBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kMainThemeColor(1);
        [[self th_getIvarsKindOfClass:[UIView class]] enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull iVarName, NSString  *_Nonnull classTypeName, BOOL * _Nonnull stop) {
            [self setValue:[self th_addsubview:NSClassFromString(classTypeName)] forKey:iVarName];
        }];
        
        
        self.searchBtn.backgroundColor = kMainThemeBackgroundColor(1);
        self.searchBtn.layer.cornerRadius = 8 ;
        self.searchBtn.clipsToBounds = YES ;
        [self.searchBtn setTitle:@"searchMusic" forState:UIControlStateNormal];
        [self.searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.searchBtn addTarget:self action:@selector(searchBarClk:) forControlEvents:UIControlEventTouchUpInside];
        
        self.searchInputTF.layer.cornerRadius = 8 ;
        self.searchInputTF.layer.borderWidth = 1 ;
        self.searchInputTF.clipsToBounds = YES ;
        self.searchInputTF.backgroundColor = kMainThemeBackgroundColor(1);
        self.searchInputTF.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        self.searchInputTF.leftViewMode = UITextFieldViewModeAlways;
        self.searchInputTF.hidden = YES ;
        self.searchInputTF.returnKeyType = UIReturnKeySearch ;
        self.searchInputTF.delegate  =  self ;
        
        [self.backBtn addTarget:self action:@selector(backCLk) forControlEvents:UIControlEventTouchUpInside];
        [self.backBtn setTitle:@"返回" forState:UIControlStateNormal];

    }
    return  self ;
}

- (void)backCLk
{
    if (self.backCallback) {
        self.backCallback();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.searchBtn.frame = self.bounds ;
    self.searchBtn.myY = 20 ;
    self.searchBtn.myX = 56 ;
    self.searchBtn.myHeight = self.myHeight - 20 ;
    self.searchInputTF.frame = self.bounds ;
    self.searchInputTF.myY = 20 ;
    self.searchInputTF.myHeight = self.myHeight - 20 ;
    self.searchInputTF.myX = 56 ;
    
    self.backBtn.frame = CGRectMake(8, 28, 40, 64-36);
}

- (void)searchBarClk:(UIButton *)sender
{
    sender.hidden = YES ;
    self.searchInputTF.hidden = NO;
    [self.searchInputTF becomeFirstResponder];
}

- (void)setTitle:(NSString *)title
{
    [self.searchBtn setTitle:title forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchInputTF resignFirstResponder];
    self.searchBtn.hidden = NO ;
    self.searchInputTF.hidden = YES ;
    if (self.searchInputTF.text.length) {
        if (self.searchStartCallback) {
            self.searchStartCallback(self.searchInputTF , self.searchInputTF.text);
        }
    }
    return  YES ;
}

- (void)setSearching:(BOOL)searching
{
    if(_searching == searching) return ;
    _searching = searching ;
    
    if (searching == NO) {
        self.searchInputTF.hidden = YES ;
        [self.searchInputTF resignFirstResponder];
        self.searchBtn.hidden = NO ;
    }
    
}

- (BOOL)endEditing:(BOOL)force
{
    self.searchBtn.hidden = NO ;
    self.searchInputTF.hidden = YES ;
    return     [super endEditing:force];

}

@end
