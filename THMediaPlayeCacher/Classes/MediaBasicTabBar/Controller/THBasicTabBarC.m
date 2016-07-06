//
//  THBasicTabBarC.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THBasicTabBarC.h"
#import "THCustomTabBar.h"
#import "THMediaPlayerVC.h"
#import "THMusicPlayController.h"
@interface THBasicTabBarC ()

@property (nonatomic,strong) NSArray *VCs;
@property (nonatomic,weak) THCustomTabBar *bar;
@property (nonatomic,strong) id<NSObject> observer;
@property (nonatomic,strong) id<NSObject> hideObserver;
@property (nonatomic,weak) THMediaPlayerVC *playerVC;

@end

@implementation THBasicTabBarC

- (instancetype)init
{
    if (self = [super init]) {
        self.tabBar.hidden = YES ;
        self.view.backgroundColor = [UIColor whiteColor];
        NSArray *childVCs= [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChildVC_ofBasicTabBar" ofType:@"plist"]];

        THCustomTabBar *bat = [[THCustomTabBar alloc] initWithBtnArr:childVCs frame:CGRectMake(0, 0, SCREEN_WIDTH_CGFloat, NAVIGATIONBAR_HEIGHT_CGFloat + STATUEBAR_HEIGHT_CGFloat)];
        [self.view addSubview:bat];
        self.bar =bat ;
        __weak typeof(self) weakSelf = self ;
        [bat setBtnClkCallback:^(NSInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;

            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.duration = 0.5 ;
            
            [strongSelf.view.layer addAnimation:transition forKey:nil];
            [strongSelf setSelectedIndex:index ];
        }];
        [childVCs enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull vcInfo, NSUInteger idx, BOOL * _Nonnull stop) {

            UIViewController *vc = [[NSClassFromString(vcInfo[@"className" ]) alloc] init];
            UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:vc];
            vc.navigationController.navigationBarHidden = YES ;
            vc.automaticallyAdjustsScrollViewInsets = NO ;
            [self addChildViewController:nav];
            
         self.observer =   [[NSNotificationCenter defaultCenter] addObserverForName:kTabbarControllerShouldShowPlayerViewNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
             self.tabBar.hidden = NO ;
                BOOL shouldShow = [note.userInfo[kTabbarControllerShouldShowPlayerViewKey] boolValue];
             
             if (shouldShow) {
                 [self.view bringSubviewToFront:self.playerVC.view];
        self.playerVC.musicToDisplay = [THMusicPlayController currentPlayerMusic];
                 [self.playerVC screenIn];

             }else
             {
                 [self.view bringSubviewToFront:self.playerVC.view];
             [self.playerVC screenOut];
             }
         }];
        }];
        
        self.hideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kTabbarControllerHideBarNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            self.tabBar.hidden = YES ;
        }];
        THMediaPlayerVC *playerVc = [[THMediaPlayerVC alloc] init];
        self.playerVC = playerVc ;
        playerVc.view.bounds = self.view.bounds ;
        [self.view addSubview:playerVc.view];
        playerVc.view.layer.position = self.view.myTailPoint;
        playerVc.view.layer.anchorPoint = CGPointMake(1, 1);
        [self addChildViewController:self.playerVC];
        [self.view bringSubviewToFront:self.tabBar];
    }
    return  self ;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    [[NSNotificationCenter defaultCenter] removeObserver:self.hideObserver];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)hiddenNavBar:(BOOL)hidden animation:(BOOL)animation
{
    [UIView animateWithDuration:animation ? 0.5 : 0 animations:^{
        self.bar.alpha = hidden ? 0 : 1 ;
    }];

}


@end
