//
//  THCustomTabBar.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/25.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THCustomTabBar : UIView

@property (nonatomic,copy) void(^btnClkCallback) (NSInteger index);

- (instancetype)initWithBtnArr:(NSArray <NSDictionary *> *)btnArr frame:(CGRect)frame;


@end
