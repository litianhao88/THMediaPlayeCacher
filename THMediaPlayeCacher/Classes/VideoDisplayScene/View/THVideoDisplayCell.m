//
//  THVideoDisplayCell.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVideoDisplayCell.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "THMediaPlayer.h"
@interface THVideoDisplayCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *imageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *iconV;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *zancaiLbl;

@end

@implementation THVideoDisplayCell
- (IBAction)shareClk:(id)sender {
}
- (IBAction)commClk:(id)sender {
}
- (IBAction)zanClk:(id)sender {
    if (!self.video.hasZaned) {
        self.zancaiLbl.text =[NSString stringWithFormat:@"%zd", self.zancaiLbl.text.integerValue + 1];
        self.video.hasZaned = YES ;
    }
}
- (IBAction)caiClk:(id)sender {
    if (!self.video.hasZaned) {
        self.zancaiLbl.text =[NSString stringWithFormat:@"%zd", self.zancaiLbl.text.integerValue - 1];
        self.video.hasZaned = YES ;
    }
}
- (IBAction)imageBtnClk:(id)sender {
    [THMediaPlayer PlayMediaAtUrl:[NSURL URLWithString:self.video.video_uri] extName:nil showInView:self.window usingDefaultBar:YES isVideo:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTabbarControllerHideBarNotificationName object:nil];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.imageBtn setImage:[UIImage imageNamed:@"player_btn_play_normal"] forState:UIControlStateNormal];
    self.imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconV.layer.cornerRadius = 15 ;
    self.iconV.clipsToBounds = YES ;
    // Initialization code
}


- (void)setVideo:(THVideoModel *)video
{
   if( [_video .Id isEqualToString: video.Id]) return ;
    _video = video ;
    self.titleLbl.text = [video.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.zancaiLbl.text = video.love;
     [self.iconV sd_setImageWithURL:[NSURL URLWithString:video.profile_image] placeholderImage:[UIImage imageNamed:@"placeHoder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         self.iconV.clipsToBounds = YES ;
     }];
    [self.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:video.profile_image] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"placeHoder"]];
    self.userName.text = [NSString stringWithFormat:@"%@\n%@" , video.name , video.create_time];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
