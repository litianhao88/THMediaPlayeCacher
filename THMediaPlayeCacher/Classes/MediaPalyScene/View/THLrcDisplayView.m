//
//  THLrcDisplayView.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/24.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THLrcDisplayView.h"

#import "THAutoColorLabel.h"

@interface THLrcDisplayView () <UITableViewDelegate , UITableViewDataSource>

@property (nonatomic,strong) NSDictionary *lrcMap;
@property (nonatomic,strong) NSArray *timeLineArr;

@property (nonatomic,assign) NSInteger currentPlayIndex;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger currentTime;
@property (nonatomic,assign) CGFloat progress;
@property (nonatomic,strong) THAutoColorLabel *currentLabel;
@property (nonatomic,assign) NSInteger shouldAutoScrollCount;

@property (nonatomic,strong) UILabel *headerLbl;

@end

@implementation THLrcDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self ;
        self.dataSource = self ;
        self.rowHeight = 38 ;
        self.sectionHeaderHeight = 38 ;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return self ;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)setViewModel:(THlrcViewModel *)viewModel
{
    _viewModel = viewModel ;
    self.lrcMap = viewModel.musicModel.lrc.lrcStringMap ;
    self.timeLineArr = viewModel.musicModel.lrc.timeLineArr;
    __weak typeof(self) weakSelf = self ;
    [_viewModel setLrcDownLoadCallBack_asyn:^(THlrcViewModel *vm){
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        strongSelf.lrcMap = vm.musicModel.lrc.lrcStringMap ;
        strongSelf.timeLineArr = vm.musicModel.lrc.timeLineArr;
        THSafeUpdateUIUsingBlock([strongSelf reloadData];
                                 strongSelf.contentOffset = CGPointMake(0, -strongSelf.myHeight/2););

        strongSelf.headerLbl.text =  [NSString stringWithFormat:@"%@-%@", vm.musicModel.songname , vm.musicModel.singername];
        [strongSelf.timer invalidate];
        strongSelf.timer = nil ;
        strongSelf.currentPlayIndex = 1 ;

    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.headerLbl)  return self.headerLbl ;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.myWidth, self.sectionHeaderHeight)];

    lbl.layer.shadowColor = [UIColor blackColor].CGColor;
    lbl.layer.shadowOffset = CGSizeMake(0, 8);
    lbl.layer.shadowOpacity = 0.5 ;
    self.headerLbl = lbl ;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.text = [NSString stringWithFormat:@"%@-%@", self.viewModel.musicModel.songname , self.viewModel.musicModel.singername];
    lbl.textColor =  kMainThemeColor(1);
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = System_Font_InstanceOfUIFont(20);
    return lbl;
}

- (void)timerAction
{
    static NSInteger index = 0;
    static  CGFloat duration = 0 ;
    if (index != self.currentPlayIndex) {
        if (self.currentPlayIndex < self.timeLineArr.count) {
            index = self.currentPlayIndex ;
            if (self.currentPlayIndex > 0) {
                CGFloat start =  [self.timeLineArr[self.currentPlayIndex-1] doubleValue] ;
                CGFloat end = [self.timeLineArr[self.currentPlayIndex ] doubleValue]  ;
                duration = end - start ;
            }
       
        }else
        {
            index = self.currentPlayIndex ;
            duration = 10 ;
        }
        self.progress = 0 ;
        [self reloadData];
    }

    self.progress += 1/(60 * duration);
    if (self.progress >1.2) {
        [self.timer invalidate];
        self.timer = nil ;
    }
    self.currentLabel.progress = self.progress  ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.timeLineArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    THAutoColorLabel *label = [cell viewWithTag:1000];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    if (label == nil) {
        label = [[THAutoColorLabel alloc] init];
        label.tag = 1000 ;
        label.backgroundColor = [UIColor clearColor];
        label.progressColor = [UIColor redColor];
        [cell.contentView addSubview:label];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        label.textAlignment = NSTextAlignmentCenter ;
        label.textColor = [UIColor orangeColor] ;
        label.font = System_Font_InstanceOfUIFont(16);
        label.layer.shadowColor = [UIColor blackColor].CGColor;
        label.layer.shadowOffset = CGSizeMake(3, 10);
        label.layer.shadowOpacity = 0.8 ;

    }
    label.text = self.lrcMap[self.timeLineArr[indexPath.row]];


    if (self.currentPlayIndex == indexPath.row ) {
        label.progressColor = [UIColor redColor] ;
        self.currentLabel = label ;
        label.font = System_Font_InstanceOfUIFont(20);

    }else if (label == self.currentLabel )
    {
        label.font = System_Font_InstanceOfUIFont(16);
        label.progressColor = label.textColor ;
    }
    [label sizeToFit];
    label.center = cell.contentView.center ;
   return cell ;
}

- (void)setCurrentLabel:(THAutoColorLabel *)currentLabel
{
    _currentLabel.progress = 0 ;
    _currentLabel = currentLabel ;
}

- (void)updateCurrentTime:(CGFloat)currentTime
{
    currentTime += 0.5;
    if (self.timeLineArr.count == 0 || currentTime < [self.timeLineArr.firstObject doubleValue]) return ;
    if (self.timer == nil) {
        self.timer = [NSTimer  timerWithTimeInterval:1/60.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    self.currentTime = currentTime ;
    while(self.currentPlayIndex != self.timeLineArr.count - 1 && [self.timeLineArr[self.currentPlayIndex + 1] doubleValue] <= currentTime) {
            self.currentPlayIndex++ ;
    }
    while (currentTime <= [self.timeLineArr[self.currentPlayIndex] doubleValue] ) {
        if (self.currentPlayIndex == 0) {
            break ;
        }else
        {
            self.currentPlayIndex --;
        }
    }
    if (self.shouldAutoScrollCount == 0) {
        [self setContentOffset:CGPointMake(0, -self.myHeight/2 +self.currentPlayIndex * self.rowHeight) animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.shouldAutoScrollCount ++;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shouldAutoScrollCount -- ;
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [@"contentOffset" isEqualToString:keyPath]) {
        self.headerLbl.backgroundColor =  kMainThemeBackgroundColor(MIN(0.8, self.contentOffset.y/300)) ;
    }
}

@end
