//
//  THMusicPlayController.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/25.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMusicPlayController.h"

#import "THMusicModel.h"

NSString *const THMusicPlayControllerNotificationName_UpdateProgress = @"THMusicPlayControllerNotificationName_UpdateProgress";
NSString *const KTHUpdateProgressTimeKey  = @"time";
typedef void(^callBackBlock)(THMusicPlayController *playController);

@interface THMusicPlayController ()

@property (nonatomic,strong) THMusicModel *musicPlaying;
@property (nonatomic,weak) UIView *ViewForControlBar;
@property (nonatomic,assign) BOOL usingDefaultBar;
@property (nonatomic,assign) BOOL isSettedBlocks;
@property (nonatomic,strong) NSMutableDictionary<NSString * , NSArray *> *blockMap;


@end

@implementation THMusicPlayController


+ (instancetype)sharedInstance
{
    static THMusicPlayController *singleTon = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleTon = [[self alloc ] init];
    });
    return singleTon ;
}

+ (void)PlayMusic:(THMusicModel *)music showInView:(UIView *)view usingDefaultBar:(BOOL)usingDefaultBar
{
    
    THMusicPlayController *controller = [self sharedInstance];
    controller.musicPlaying = music ;
    controller.ViewForControlBar = view ;
    controller.usingDefaultBar = usingDefaultBar ;
    [controller configMediaPlayer];
}


- (void)configMediaPlayer
{
    THMediaPlayer *mediaPlayer = [THMediaPlayer PlayMediaAtUrl:[NSURL URLWithString:_musicPlaying.playUrlString] extName:_musicPlaying.extname showInView:self.ViewForControlBar usingDefaultBar:self.usingDefaultBar isVideo:NO];

    if (_isSettedBlocks == NO) {
        _isSettedBlocks = YES ;
    __weak typeof(self) weakSelf = self ;
    [mediaPlayer setUpdateProcessCallBack:^(CGFloat time) {
        [[NSNotificationCenter defaultCenter] postNotificationName:THMusicPlayControllerNotificationName_UpdateProgress object:nil userInfo:@{ KTHUpdateProgressTimeKey : @(time)}];
    }];
    
    [mediaPlayer setNextBtnClk:^{
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        [strongSelf.blockMap[kNextBtnClkKey] enumerateObjectsUsingBlock:^(callBackBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
            block(self);
        }];
    }];
    
    [mediaPlayer setPreBtnClk:^{
        __strong typeof(weakSelf) strongSelf = weakSelf ;
    [strongSelf.blockMap[kPreBtnClk] enumerateObjectsUsingBlock:^(callBackBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
        block(self);
    }];
    }];
    [mediaPlayer setShouldPlayNxtCallBack:^{
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        [strongSelf.blockMap[kShouldPlayNxtBlock] enumerateObjectsUsingBlock:^(callBackBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
            block(self);
        }];
     }];
    }
}

+ (void)addBlock:(void(^)())block forKey:(NSString *)key
{
    THMusicPlayController *controller = [self sharedInstance] ;
    NSArray *arr = [controller.blockMap objectForKey:key];
    if (arr == nil ) {
        arr = @[block];
    }else
    {
        arr = [arr arrayByAddingObject:block];
    }
    [controller.blockMap setObject:arr forKey:key];
}

static NSString * const kNextBtnClkKey = @"nextBtnClk";
+ (void)addNextBtnClkBlock:(void(^)(THMusicPlayController *playController))nextBtnClk
{
    [self addBlock:nextBtnClk forKey:kNextBtnClkKey];
}
static NSString * const kPreBtnClk = @"preBtnClk";
+ (void)addPreBtnClkBlock:(void(^)(THMusicPlayController *playController))preBtnClk
{
    [self addBlock:preBtnClk forKey:kPreBtnClk];

}
static NSString * const kShouldPlayNxtBlock = @"shouldPlayNxtBlock";
+ (void)addShouldPlayNxtBlock:(void(^)(THMusicPlayController *playController))shouldPlayNxtBlock
{
    [self addBlock:shouldPlayNxtBlock forKey:kShouldPlayNxtBlock];
}

+ (void)setTitle:(NSString *)title controlBarClkCallback:(void (^)())controlBarClkCallback
{
    [THMediaPlayer setTitle:title controlBarClkCallback:controlBarClkCallback];
}

+ (void)setControlBarIcon:(UIImage *)icon
{
    [THMediaPlayer setControlBarIcon:icon];
}

- (NSMutableDictionary<NSString * , NSArray *> *)blockMap
{
    if (!_blockMap) {
        _blockMap = [NSMutableDictionary dictionary];
    }
    return _blockMap;
}

+ (THMusicModel *)currentPlayerMusic
{
    return [[self sharedInstance] musicPlaying];
}

@end
