//
//  THMusicList.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMusicList.h"
#import "UIImageView+WebCache.h"
#import "THMediaDataCacheManager.h"
#import "NSObject+THRuntimeEx.h"
@interface THMusicList ()

@property (nonatomic,weak) UIImageView *icon;
@property (nonatomic,weak) UILabel *songname;
@property (nonatomic,weak) UILabel *detail;
@end

@implementation THMusicList

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        [[self th_getIvarsKindOfClass:[UIView class]] enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull iVarName, NSString  *_Nonnull classTypeName, BOOL * _Nonnull stop) {
            [self setValue:[self th_addsubview:NSClassFromString(classTypeName)] forKey:iVarName];
        }];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.backgroundView = backView;

    }
    return self ;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(8, 8, 48, 48);
    self.songname.frame = CGRectMake(self.icon.myTailPoint.x + 8, 8, self.myWidth - self.icon.myWidth - 24 / 2, 24);
    self.detail.frame = CGRectMake(self.songname.myX, self.songname.myTailPoint.y+ 3, self.songname.myWidth * 2, 24);
    self.icon.clipsToBounds = YES ;
    self.icon.layer.cornerRadius = self.icon.myWidth/2 ;
}

- (void)setMusic:(THMusicModel *)music
{
    _music = music ;
    [self.icon sd_setImageWithURL:[NSURL URLWithString:music.singer.image] placeholderImage:[UIImage imageNamed:@"placeHoder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"%@" , self.music.songname);
        self.icon.clipsToBounds = YES ;
        self.icon.layer.cornerRadius = self.icon.myWidth/2 ;
    }];
    self.songname.text = [NSString stringWithFormat:@"%@-%@",music.songname , music.singername ];

    NSURL *url = [NSURL URLWithString:music.playUrlString];
    NSArray *arr =  [THMediaDataCacheManager  rangesOfUrl:url] ;
    
    NSInteger length = [THMediaDataCacheManager totalLengthOfUrl:url];
    NSMutableString *str = [NSMutableString string];
    [arr enumerateObjectsUsingBlock:^(NSValue  *_Nonnull rangeV, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangeTemp = rangeV.rangeValue ;
        
        [str appendFormat:@"%.2f%%~%.2f%% ;" , 100.0 *rangeTemp.location/length ,100.0 * rangeTemp.length/length  ] ;
        
    }];
    self.detail.text = str;
    self.icon.clipsToBounds = YES ;
    self.icon.layer.cornerRadius = self.icon.myWidth/2 ;
}

@end
