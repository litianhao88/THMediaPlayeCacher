//
//  THVideoModel.h
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THVideoModel : NSObject
/*
 "text": "\n        中国平衡能力最厉害的美女,不服不行!\n    ",
 "hate": "103",
 "videotime": "0",
 "voicetime": "0",
 "weixin_url": "http://m.budejie.com/detail-19096285.html/",
 "profile_image": "http://dimg.spriteapp.cn/profile/large/2016/06/20/5767f8cfce9e0_mini.jpg",
 "width": "0",
 "voiceuri": "",
 "type": "41",
 "id": "19096285",
 "love": "472",
 "height": "0",
 "video_uri": "http://bvideo.spriteapp.cn/video/2016/0628/e05447f4-3cdd-11e6-ba50-d4ae5296039d_wpstar.mp4",
 "voicelength": "0",
 "name": "百思仙女V大仙女",
 "create_time": "2016-06-29 23:48:02"
 */
@property (nonatomic,copy) NSString *Id;
@property (nonatomic,copy) NSString *text;
@property (nonatomic,copy) NSString *love;
@property (nonatomic,copy) NSString *video_uri;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *create_time;
@property (nonatomic,copy) NSString *profile_image;
@property (nonatomic,copy) NSString *image1;
@property (nonatomic,assign) BOOL hasZaned;
+ (instancetype)videoWithDict:(NSDictionary *)dict;
@end
