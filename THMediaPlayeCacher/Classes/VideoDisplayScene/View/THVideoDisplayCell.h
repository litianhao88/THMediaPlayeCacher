//
//  THVideoDisplayCell.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THVideoModel.h"
@interface THVideoDisplayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zancaiTopCOntrant;
@property (nonatomic,strong) THVideoModel *video;


@end
