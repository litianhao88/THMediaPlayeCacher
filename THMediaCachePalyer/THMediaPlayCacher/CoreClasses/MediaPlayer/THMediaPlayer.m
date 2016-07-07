//
//  THMediaPlayer.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/20.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaPlayer.h"
#import "AFNetworking.h"
// 媒体播放相关
#import "THMediaDataProvider.h"
#import <AVFoundation/AVFoundation.h>
#import "CommonMarco.pch"
#import "MediaCacheMap.h"
// 缓存
#import "THMediaDataCacheManager.h"
// 控制条
#import "THMediaPlayerControlBar.h"
//你懂得
#import "MBProgressHUD+Show.h"
#import "THNetWorkManager.h"
#import "THVideoView.h"
#import "THVideoControlBar.h"
static CGFloat const controlBarHeight = 80 ;

NSString *const kTHMediaPlayerPresentAlertControllerNotificationName = @"kTHMediaPlayerPresentAlertControllerNotificationName";
NSString *const kTHMediaPlayerPresentAlertControllerKey = @"kTHMediaPlayerPresentAlertControllerKey" ;


@interface THMediaPlayer ()

/*******************************************************************************/
#pragma mark -数据获取相关
/*******************************************************************************/
@property (nonatomic,weak) id test;
@property (nonatomic,strong) AVPlayer *mediaPlayer;

/// 播放器依靠这个中间类获得数据 这个类依靠缓存管理器得知需要从网络还是从本地缓存读数据
@property (nonatomic,strong) THMediaDataProvider *mediaDataProvider;

///  真正播放媒体的AVPlayer
/// AVPlayer中的 urlAsset  设置它的resourceLoader的代理 来截取avplayer的网络请求 达到缓存播放目的
@property (nonatomic,strong) AVURLAsset *mediaUrlAsset;
/// 将mediaUrlAsset 与 avplayer 联系起来的中间层 可以用KVO监听它的某些keypath 来获取播放状态
@property (nonatomic,strong) AVPlayerItem *currentPlayerItem;
/// 当前媒体文件的总时长
@property (nonatomic,assign) NSTimeInterval currentDuration;
///当前播放媒体是否是本地缓存文件
@property (nonatomic,assign) BOOL cancelPlay;

@property (nonatomic,strong) THVideoView *videoView;
@property (nonatomic,assign) BOOL userPause;
/*******************************************************************************/
#pragma mark -展示UI相关
/*******************************************************************************/
@property (nonatomic , strong , readwrite) UIView *view;
@property (nonatomic,strong) THMediaPlayerControlBar *controlBar;

@property (nonatomic,assign) NSInteger autoHiddenBarCount;

@property (nonatomic,strong) NSURL *resultUrl;
@property (nonatomic,weak) id timeobserver;
@property (nonatomic,strong) THVideoControlBar *videoControllBar;
@end

@implementation THMediaPlayer

static THMediaPlayer *mediaPlayer = nil ;

+ (instancetype)defaultMediaPlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaPlayer = [[self alloc] init];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    });
    return  mediaPlayer ;
}

- (THVideoView *)videoView
{

    if (!_videoView) {
        _videoView = [[THVideoView alloc] init];
        __weak typeof(self) weakSelf = self ;

        [_videoView setStopPlayCallBack:^{
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            [strongSelf.mediaPlayer pause];
            [strongSelf.mediaPlayer setRate:0];
            [strongSelf.mediaUrlAsset cancelLoading];

            [strongSelf.mediaPlayer replaceCurrentItemWithPlayerItem:nil];
            [strongSelf.mediaPlayer removeTimeObserver:strongSelf.timeobserver];
            [strongSelf.mediaPlayer.currentItem cancelPendingSeeks];
            [strongSelf.mediaPlayer.currentItem.asset cancelLoading];
            [strongSelf.mediaDataProvider cancelAndSave];

        }];
    }
    return  _videoView ;
}

- (void)dealloc
{
   if (_controlBar.superview) {
        [_controlBar.superview removeObserver:self forKeyPath:@"frame"];
        [_controlBar removeFromSuperview];
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignNotifications];
}

+ (instancetype)PlayMediaAtUrl:(NSURL *)mediaUrl extName:(NSString *)extName showInView:(UIView *)view usingDefaultBar:(BOOL) usingDefaultBar isVideo:(BOOL)isVideo
{
    [THMediaDataCacheManager setCurrentExtName:extName];

    THMediaPlayer *mediaP = [self defaultMediaPlayer];
    mediaP.resultUrl = mediaUrl ;
    [mediaP dealWithUrl:mediaUrl];
    if (usingDefaultBar && view) {
        if (isVideo == NO) {
            mediaP.controlBar.hidden = NO ;
            if (mediaP.controlBar.superview) {
                [mediaP.controlBar.superview removeObserver:mediaP forKeyPath:@"frame"];
                [mediaP.controlBar removeFromSuperview];
            }
            [view addObserver:mediaP forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            mediaP.controlBar.frame = CGRectMake(0, view.myHeight- controlBarHeight, view.myWidth, controlBarHeight);
            [view addSubview:mediaP.controlBar];

        }else
        {
            mediaP.controlBar.hidden = YES ;
            if (mediaP.videoView.superview ) {
                [mediaP.videoView removeFromSuperview];
            }
        mediaP.videoView.frame = view.bounds ;
            mediaP.videoView.controlBar  = mediaP.videoControllBar;
        [mediaP.videoView setPlayer:mediaP.mediaPlayer];
        [view addSubview:mediaP.videoView];
        }
    }

    return mediaPlayer;
}

- (void)dealWithUrl:(NSURL *)url
{
    
    if (url == nil)
    {
        [MBProgressHUD showErrorWithText:@"媒体链接失效!"] ;
        return ;
    }
     NSArray *ranges =  [THMediaDataCacheManager rangesOfUrl:url];
  
        long long totalLength = [THMediaDataCacheManager totalLengthOfUrl:url];
        [self.controlBar configProgressBarWithTotalLength:totalLength ranges:[ranges mutableCopy]];
    [self.videoControllBar configProgressBarWithTotalLength:totalLength ranges:[ranges mutableCopy]];

    
    NSString *localFilePath = [THMediaDataCacheManager finishDownloadedFilePathWithUrl:url];
    
    if(localFilePath.length)
    {
        [MBProgressHUD showSuccessWithText:@"使用磁盘缓存"];
        self.resultUrl =  [NSURL fileURLWithPath:localFilePath];
        [self configPlayerComponentsWithUrl:self.resultUrl];
        return ;
    }
    
    AFNetworkReachabilityStatus status =  [THNetWorkManager currentNetworkReachabilityStatus] ;
    if ( AFNetworkReachabilityStatusReachableViaWWAN  == status ) {
        [MBProgressHUD showErrorWithText:@"当前使用流量播放"];
        self.resultUrl = [self.resultUrl th_UrlByReplaceSchemeName:@"stream"];
        [self configPlayerComponentsWithUrl:self.resultUrl];     }else if (AFNetworkReachabilityStatusNotReachable == status ) {
        [MBProgressHUD showErrorWithText:@"网络不可获得 , 无法播放在线媒体"];
        if (ranges.count) {
            self.resultUrl = [self.resultUrl th_UrlByReplaceSchemeName:@"stream"];
            [self configPlayerComponentsWithUrl:self.resultUrl] ;
        }
 
    }else if( AFNetworkReachabilityStatusReachableViaWiFi  == status)
    {
        [MBProgressHUD showErrorWithText:@"当前使用WIFI网络"];
        self.resultUrl = [self.resultUrl th_UrlByReplaceSchemeName:@"stream"];
        [self configPlayerComponentsWithUrl:self.resultUrl];
    }
    else
    {
        [MBProgressHUD showSuccessWithText:@"加载网络数据"];
        self.resultUrl = [self.resultUrl th_UrlByReplaceSchemeName:@"stream"];
        [self configPlayerComponentsWithUrl:self.resultUrl];
    }
}
- (void)setCancelPlay:(BOOL)cancelPlay
{
    _cancelPlay = cancelPlay ;
    if (!cancelPlay) {
        self.resultUrl = [self.resultUrl th_UrlByReplaceSchemeName:@"stream"];
        [self configPlayerComponentsWithUrl:self.resultUrl];
    }
}

- (void)showWWANAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"当前出于3G网络 , 是否使用流量播放媒体" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"没钱就要低调点,不听了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.cancelPlay = YES ;
    }];
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"有钱任性 , 就要听" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.cancelPlay = NO ;
    }];
    [alert addAction:action];
    [alert addAction:continueAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTHMediaPlayerPresentAlertControllerNotificationName object:nil userInfo:@{kTHMediaPlayerPresentAlertControllerKey : alert}];
}

- (void)configPlayerComponentsWithUrl:(NSURL *)url
{
    if (self.mediaUrlAsset) {
        [self.mediaUrlAsset cancelLoading];
//        [self.mediaDataProvider cancelLodaing];
    }


      self.mediaDataProvider = [[THMediaDataProvider alloc] init];
    __weak typeof(self) weakSelf = self ;
    [self.mediaDataProvider setUpdateProgressCallback:^(NSValue *progress , CGFloat totalValue) {
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        if (strongSelf.controlBar.hidden == NO) {
            [strongSelf.controlBar configTotalValue:totalValue];
            [strongSelf.controlBar updateCurrentProgress:progress];
        }else
        {
            [strongSelf.videoControllBar configTotalValue:totalValue];
            [strongSelf.videoControllBar updateCurrentProgress:progress];
        }
    }];
    self.mediaUrlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    [self.mediaUrlAsset.resourceLoader setDelegate:self.mediaDataProvider queue:dispatch_get_main_queue()];
    if (self.currentPlayerItem) {
        [self resignNotifications];
    }
    self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:self.mediaUrlAsset];
    [self.mediaPlayer removeTimeObserver:self.timeobserver];
    [self.mediaPlayer pause];
    self.mediaPlayer  = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];

    [self configNotification];

    [self.mediaPlayer play];
}

- (void)configNotification
{
    
    [self.mediaPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.mediaPlayer.currentItem  addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.mediaPlayer.currentItem  addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.mediaPlayer.currentItem  addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    //后台播放相关
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //avplayer发送的播放状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:self.currentPlayerItem];
}

- (void)resignNotifications
{

    [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
//    [self.view removeObserver:self forKeyPath:@"frame"];

    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _controlBar.superview && [@"frame" isEqualToString:keyPath] ) {
        CGRect superViewBounds =   _controlBar.superview.bounds ;
        _controlBar.frame = CGRectMake(0, superViewBounds.size.height - controlBarHeight, superViewBounds.size.width, controlBarHeight);
        return ;
    }
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self monitoringPlayback:playerItem];// 给播放器添加计时器

            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {

        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度

        [self calculateDownloadProgress:playerItem];

    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态
        if (playerItem.isPlaybackBufferEmpty) {
            [self bufferingSomeSecond];
        }
    }else if ([@"playbackLikelyToKeepUp" isEqualToString:keyPath])
    {
        if (playerItem.isPlaybackBufferEmpty) {
            
            [self bufferingSomeSecond];
        }    }
}


- (void)monitoringPlayback:(AVPlayerItem *)playerItem
{
    if (self.controlBar.hidden == NO) {
        self.controlBar.playing = YES ;
    }else
    {
        self.videoControllBar.playing = YES ;
    }
    self.currentDuration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    [self.mediaPlayer play];
    if (self.controlBar.hidden == NO) {
    [self.controlBar setTotalTime:self.currentDuration];
    }else
    {
        [self.videoControllBar setTotalTime:self.currentDuration];
    }
    
    __weak __typeof(self)weakSelf = self;
  self.timeobserver =  [self.mediaPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:NULL usingBlock:^(CMTime time) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        CGFloat current = playerItem.currentTime.value/playerItem.currentTime.timescale;
      if (strongSelf.controlBar.hidden == NO) {
          [strongSelf.controlBar setCurrentTime:current];
      }else
      {
      [strongSelf.videoControllBar setCurrentTime:current];
      }
        if (strongSelf.updateProcessCallBack && strongSelf.controlBar.hidden == NO) {
            strongSelf.updateProcessCallBack(current);
        }
        }];
    
}

- (void)calculateDownloadProgress:(AVPlayerItem *)playerItem
{
    
    CMTime duration = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(duration);
    if (self.controlBar.hidden == NO) {
        [self.controlBar setTotalTime:totalDuration];
    }else
    {
        [self.videoControllBar setTotalTime:totalDuration];
    }
    [self.mediaPlayer  play];
}

#pragma mark - 四个通知回调
//通知名 : UIApplicationWillResignActiveNotification
- (void)appDidEnterBackground
{
}

//通知名 : UIApplicationDidBecomeActiveNotification
- (void)appDidEnterPlayGround
{
}

//通知名 : AVPlayerItemDidPlayToEndTimeNotification
- (void)playerItemDidPlayToEnd:(NSNotification *)notify
{
    [self.mediaPlayer pause];
    self.controlBar.playing = NO ;
    self.videoControllBar.playing = NO ;
    if (self.shouldPlayNxtCallBack) {
        self.shouldPlayNxtCallBack();
    }
}

//通知名 : AVPlayerItemPlaybackStalledNotification
- (void)playerItemPlaybackStalled:(NSNotification *)notify
{
    // 这里网络不好的时候，就会进入，不做处理，会在playbackBufferEmpty里面缓存之后重新播放
//    NSLog(@"buffing-----buffing");
}

- (void)viewTapGes:(UITapGestureRecognizer *)tapGes
{
    [self.controlBar displayBar];
}

- (THVideoControlBar *)videoControllBar
{
    if (!_videoControllBar) {
        _videoControllBar = [[THVideoControlBar alloc] init];
        [_videoControllBar displayBar];
        __weak typeof(self) weakSelf = self ;
        [_videoControllBar setPlayBtnClkCallback:^(BOOL shouldPlay) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (shouldPlay) {
                strongSelf.userPause = NO ;
                [strongSelf.mediaPlayer play];
            }else
            {
                strongSelf.userPause = YES ;
                [strongSelf.mediaPlayer pause];
            }
        }];
        

        
        [_videoControllBar setSeekToTimeCallBack:^(NSTimeInterval time) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (strongSelf.currentPlayerItem.status != AVPlayerItemStatusReadyToPlay) return ;
            CMTime cmTime = CMTimeMake(time, 1);
            CGFloat progress = time / self.currentDuration ;
            NSInteger offset = [THMediaDataCacheManager totalLengthOfUrl:[strongSelf.resultUrl th_UrlByReplaceSchemeName:@"http"]] * progress;
            strongSelf.mediaDataProvider.currentRequestOffset = offset ;
            strongSelf.mediaDataProvider.shouldCancelPreRequest = YES ;
            [strongSelf.mediaPlayer pause];
            [strongSelf.mediaPlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
                [strongSelf.mediaPlayer play];
            }];
        }];

    }
    return  _videoControllBar ;
}

- (THMediaPlayerControlBar *)controlBar
{
    if (!_controlBar) {
        _controlBar = [[THMediaPlayerControlBar alloc] init];
        [_controlBar displayBar];
        __weak typeof(self) weakSelf = self ;
        [_controlBar setPlayBtnClkCallback:^(BOOL shouldPlay) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (shouldPlay) {
                [strongSelf.mediaPlayer play];
            }else
            {
                [strongSelf.mediaPlayer pause];
            }
        }];
        
        [_controlBar setNextBtnClk:^{
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (strongSelf.nextBtnClk) {
                strongSelf.nextBtnClk();
            }
        }];
        
        [_controlBar setPreBtnClk:^{
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            if (strongSelf.preBtnClk) {
                strongSelf.preBtnClk();
            }
        }];
        
        [_controlBar setSeekToTimeCallBack:^(NSTimeInterval time) {
            __strong typeof(weakSelf) strongSelf = weakSelf ;
//            if (strongSelf.currentPlayerItem.status != AVPlayerItemStatusReadyToPlay) return ;
            CMTime cmTime = CMTimeMake(time, 1);
            CGFloat progress = time / self.currentDuration ;
            NSInteger offset = [THMediaDataCacheManager totalLengthOfUrl:[strongSelf.resultUrl th_UrlByReplaceSchemeName:@"http"]] * progress;
            strongSelf.mediaDataProvider.currentRequestOffset = offset ;
            strongSelf.mediaDataProvider.shouldCancelPreRequest = YES ;
            [strongSelf.mediaPlayer pause];
                [strongSelf.mediaPlayer seekToTime:cmTime completionHandler:^(BOOL finished) {
                    [strongSelf.mediaPlayer play];
                }];
        }];
        
    }
    return  _controlBar ;
}

- (void)bufferingSomeSecond
{
    if (self.userPause) {
        return ;
    }
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    static BOOL isBuffering = NO;
    static NSInteger count = 0 ;
    if (isBuffering) {
        return;
    }
    isBuffering = YES;
    count ++ ;
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.mediaPlayer pause];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mediaPlayer play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            if (count >3) {
                [self.mediaPlayer pause];
                [MBProgressHUD showErrorWithText:@"网络不佳 停止播放"];
                count = 0 ;
            }else{
                [self.mediaDataProvider resumeSomeRequest];

            [self bufferingSomeSecond];
            }
        }else{
            count = 0 ;
        }
    });
}


+ (void)setControlBarIcon:(UIImage *)icon
{
    THMediaPlayer *player = [self defaultMediaPlayer];
    [player.controlBar setIconImage:icon];
}
+ (void)setTitle:(NSString *)title controlBarClkCallback:(void (^)())controlBarClkCallback
{
    THMediaPlayer *player = [self defaultMediaPlayer];

    [player.controlBar setTitle:title];
    [player.controlBar setControlBarClkCallback:controlBarClkCallback];
}

@end
