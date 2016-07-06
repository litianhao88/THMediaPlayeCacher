//
//  THSearchBar.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THSearchBar : UIView

@property (nonatomic,copy) void(^searchStartCallback)(UITextField *inputTF ,  NSString *searchText);
@property (nonatomic,copy) void(^backCallback) ();
@property (nonatomic,assign) BOOL searching;
- (void)setTitle:(NSString *)title;


@end
