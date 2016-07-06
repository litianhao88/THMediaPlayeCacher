//
//  THMediaPlayerVC.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaPlayerVC.h"

#import "THMusicModel.h"
#import "THMusicListModel.h"
#import "THSingerModel.h"
#import "THlrcViewModel.h"

#import "THMusicPlayController.h"
#import "THLrcDisplayView.h"

#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"

#import "THMediaPlayer.h"
#import <AVFoundation/AVFoundation.h>
@interface THMediaPlayerVC ()<UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *navAndTabbarDisplayConfigDictM;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,copy) NSString *currentFileExtName;
@property (nonatomic,strong) THMusicListModel *musicList;
@property (nonatomic,assign) NSUInteger indexer;

@property (nonatomic,assign) BOOL shouldLoadPlayer;

@property (nonatomic,weak) THLrcDisplayView *lrcView;
@property (nonatomic,strong) THlrcViewModel *lrcViewModel;

@property (nonatomic,strong) UIScrollView *centerContainerView;
@property (nonatomic,weak) UIImageView *imageBackV;
@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) NSTimer *icontimer;
@property (nonatomic,weak) UILabel *titleLbl;
@property (nonatomic,strong) UIView *snapV;
@property (nonatomic,strong) id<NSObject> observer;
@property (nonatomic,assign) BOOL circleBool;
@end

@implementation THMediaPlayerVC

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.centerContainerView) {
        self.snapV.alpha = 1 - self.centerContainerView.contentOffset.x / self.centerContainerView.myWidth ;
    }

}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.centerContainerView) {
        if (scrollView.contentOffset.x == scrollView.myX) {
            self.snapV = [self.centerContainerView snapshotViewAfterScreenUpdates:NO];
            self.snapV.frame = self.centerContainerView.frame ;
            [self.view addSubview:self.snapV];
            self.iconView.hidden = self.titleLbl.hidden = YES ;
            self.circleBool = YES ;
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.centerContainerView) {
        if (scrollView.contentOffset.x == scrollView.myX) {
            [self.snapV removeFromSuperview];
            self.iconView.hidden = self.titleLbl.hidden = NO ;
            self.circleBool = NO ;
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}
#pragma mark - view 进出屏幕方法
- (void)screenIn
{
    self.view.hidden = NO ;
   self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:THMusicPlayControllerNotificationName_UpdateProgress object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [self.lrcView updateCurrentTime:[note.userInfo[KTHUpdateProgressTimeKey] doubleValue]];
    }];
    [UIView animateWithDuration:1 animations:^{
        self.view.layer.affineTransform =  CGAffineTransformIdentity;
    }];
}
- (void)screenOut
{
    [UIView animateWithDuration:1 animations:^{
        self.view.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
    } completion:^(BOOL finished) {
        [self.icontimer invalidate];
        self.icontimer = nil ;
        self.view.hidden = YES ;
    }];
    
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    self.view.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
}


#pragma mark - 数据加载方法
- (void)setMusicToDisplay:(THMusicModel *)musicToDisplay
{
    if ([_musicToDisplay.HASH isEqualToString:musicToDisplay.HASH])
    {
        if (self.icontimer == nil) {
            self.icontimer = [NSTimer timerWithTimeInterval:1/10.0 target:self selector:@selector(iconCircle) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.icontimer forMode:NSRunLoopCommonModes];
        }
        return ;
    }
    _musicToDisplay = musicToDisplay ;
    self.url = [NSURL URLWithString:[musicToDisplay playUrlString]];
    self.currentFileExtName = [ musicToDisplay extname];
    self.lrcViewModel.musicModel = musicToDisplay ;
    
    __weak typeof(self) weakSelf = self ;
    if (self.icontimer.isValid) {
        [self.icontimer invalidate];
        self.icontimer = nil ;
        self.iconView.transform = CGAffineTransformIdentity;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.titleLbl.text = [NSString stringWithFormat:@"%@ - %@" , musicToDisplay.songname , musicToDisplay.singername];
    });
    self.iconView.image = [UIImage imageNamed:@"placeHoder"];
    self.imageBackV.image = [[UIImage imageNamed:@"placeHoder"] applyDarkEffect];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:musicToDisplay.singer.image] options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        if (error) {
            NSLog(@"%@" ,error);
            return ;
        }
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        strongSelf.iconView.image = image ;
        if (strongSelf.icontimer == nil) {
            strongSelf.icontimer = [NSTimer timerWithTimeInterval:1/10.0 target:self selector:@selector(iconCircle) userInfo:nil repeats:YES];
        }
        [[NSRunLoop mainRunLoop] addTimer:strongSelf.icontimer forMode:NSRunLoopCommonModes];
        
        UIImage *blurImage = [image applyDarkEffect];
        THSafeUpdateUIUsingBlock(strongSelf.imageBackV.image = blurImage ;);
    }];
    [self.lrcView reloadData];
    
}

#pragma mark - UI设置

- (void)configGesture
{
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesAction:)];
    [self.view addGestureRecognizer:panGes];
}

- (void)configUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO ;
    [self configBackImageView];
    [self configCenterContainerView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 30)];
    [btn setTitle:@"<==" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(screenOut) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    [self configGesture];
}


- (void)configBackImageView
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageBackV = image ;
    image.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:image];
    
}
- (void)configCenterContainerView
{
    self.centerContainerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,STATUEBAR_HEIGHT_CGFloat + 30 , SCREEN_WIDTH_CGFloat, SCREEN_HEIGHT_CGFloat- STATUEBAR_HEIGHT_CGFloat - 30 - 80)];
    self.centerContainerView.contentSize = CGSizeMake(self.view.myWidth*2, 0);
    [self.view addSubview:self.centerContainerView];
    self.centerContainerView.pagingEnabled = YES ;
    self.centerContainerView.bounces = NO ;
    self.centerContainerView.showsVerticalScrollIndicator = NO ;
    self.centerContainerView.showsHorizontalScrollIndicator = NO ;
    self.centerContainerView.delegate = self ;
    [self configIconV];
    [self configTitleLabel];
    [self configLrcView];

    
}

- (void)configIconV
{
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_CGFloat*5/6, SCREEN_WIDTH_CGFloat*5/6)];
    self.iconView.center = CGPointMake(self.centerContainerView.center.x, self.iconView.myHeight/2 + 70);
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = self.iconView.bounds;
    UIBezierPath *cirPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.iconView.myWidth/2, self.iconView.myHeight/2) radius:self.iconView.myHeight/2 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    UIBezierPath *innerCirPath =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.iconView.myWidth/2, self.iconView.myHeight/2) radius:self.iconView.myHeight/2 - 45  startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [cirPath appendPath:innerCirPath];
    layer.path = cirPath.CGPath ;
    layer.fillMode = kCAFillRuleNonZero ;
    UIGraphicsBeginImageContext(self.iconView.mySize);
 

    CALayer *backLayer = [CALayer layer];

    backLayer.contents = CFBridgingRelease([UIImage imageNamed:@"changpianbeijing"].CGImage);
    backLayer.frame = self.iconView.bounds ;
    backLayer.mask = layer ;
    [self.iconView.layer addSublayer:backLayer];
    
    
        self.iconView.layer.cornerRadius = self.iconView.myWidth/2;

    self.iconView.clipsToBounds = YES ;
    self.iconView.contentMode = UIViewContentModeScaleAspectFill ;
    [self.centerContainerView addSubview:self.iconView];
}

- (void)configTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.centerContainerView.myWidth, 50)];
    titleLabel.center = CGPointMake(self.centerContainerView.center.x, 36);
    titleLabel.textColor = [UIColor orangeColor];
    titleLabel.font = System_Font_InstanceOfUIFont(20);
    self.titleLbl = titleLabel ;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.centerContainerView addSubview:titleLabel];
    
}
- (void)configLrcView
{
    THLrcDisplayView *lrcView = [[THLrcDisplayView alloc] initWithFrame:CGRectMake(self.centerContainerView.myWidth,0, self.centerContainerView.myWidth, self.centerContainerView.myHeight)];
    
    self.lrcView = lrcView ;
    lrcView.viewModel =  self.lrcViewModel;
    [self.centerContainerView addSubview:self.lrcView];
}

- (void)iconCircle
{
    if (!self.circleBool) {
        self.iconView.transform = CGAffineTransformRotate(self.iconView.transform, M_PI_4/100);
    }
}

- (void)panGesAction:(UIPanGestureRecognizer *)panGes
{
    CGPoint translationP = [panGes translationInView:panGes.view] ;
    if(UIGestureRecognizerStateChanged == panGes.state )
    {
        self.view.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2 * translationP.x);
    }else if ( UIGestureRecognizerStateEnded == panGes.state)
    {
        if (translationP.x  > self.view.myWidth/3) {
            [UIView animateWithDuration:0.25 animations:^{
                self.view.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
            }];
        }
    }
}

#pragma mark - lazy load
- (THlrcViewModel *)lrcViewModel
{
    if (!_lrcViewModel) {
        _lrcViewModel = [[THlrcViewModel alloc] init];
    }
    return _lrcViewModel ;
}

- (NSMutableDictionary *)navAndTabbarDisplayConfigDictM
{
    if (!_navAndTabbarDisplayConfigDictM) {
        _navAndTabbarDisplayConfigDictM = [NSMutableDictionary dictionary];
    }
    return  _navAndTabbarDisplayConfigDictM ;
}



#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navAndTabbarDisplayConfigDictM setObject:@(self.navigationController.navigationBarHidden) forKey:@"navBarHiddenKay"];
    self.navigationController.navigationBarHidden = YES ;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = [self.navAndTabbarDisplayConfigDictM[@"navBarHiddenKay"] boolValue];
    [self.navAndTabbarDisplayConfigDictM removeAllObjects];
}

@end
