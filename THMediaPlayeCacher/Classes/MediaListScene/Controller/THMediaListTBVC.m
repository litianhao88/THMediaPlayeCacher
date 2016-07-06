//
//  THMediaListTBVC.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THMediaListTBVC.h"

#import "THMusicModel.h"
#import "THMusicListModel.h"
#import "THMusicListManager.h"
#import "THSingerModel.h"

#import "UIImageView+WebCache.h"
#import "THMediaPlayer.h"

#import "SDWebImageDownloader.h"

#import "THMusicPlayController.h"
#import "THMediaDataCacheManager.h"
#import "THMediaPlayer.h"
#import "THSearchVC.h"
#import "THMusicList.h"
static NSString *const reuseId = @"reuseId";

@interface THMediaListTBVC ()

@property (nonatomic,strong) NSMutableDictionary *musicListDict;
@property (nonatomic,strong) NSArray *musicListDictKeySortedArr;
@property (nonatomic,weak) UITextField *addListInputNameTF;
@property (nonatomic,strong) NSIndexPath *currentEditIndexPath;
@property (nonatomic,strong) NSMutableArray *hidenSections;

@end

@implementation THMediaListTBVC

- (NSMutableArray *)hidenSections
{
    if (!_hidenSections) {
        _hidenSections = [NSMutableArray    array];
    }
    return  _hidenSections ;
}

- (void)configBackImageView
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.image = [UIImage imageNamed:@"placeHoder"];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = image ;
    [self.tabBarController.view insertSubview:image atIndex:0];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[THMusicList class] forCellReuseIdentifier:@"cell"];
    [self configBackImageView];
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.rowHeight = 38;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0 , 49, 0);
    
    __weak typeof(self) weakSelf = self ;
[THMusicPlayController addShouldPlayNxtBlock:^(THMusicPlayController *playController) {
    __strong typeof(weakSelf) strongSelf = weakSelf ;
    NSIndexPath *path = [strongSelf.tableView indexPathForSelectedRow];
    path = [NSIndexPath indexPathForRow:(path.row + 1 )%([strongSelf.musicListDict[ self.musicListDictKeySortedArr[path.section]] musics].count) inSection:path.section];
    [strongSelf.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    [strongSelf tableView:strongSelf.tableView didSelectRowAtIndexPath:path];
}];
    
    [THMusicPlayController addNextBtnClkBlock:^(THMusicPlayController *playController) {
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        NSIndexPath *path = [strongSelf.tableView indexPathForSelectedRow];
        path = [NSIndexPath indexPathForRow:(path.row + 1 )%([strongSelf.musicListDict[ self.musicListDictKeySortedArr[path.section]] musics].count) inSection:path.section];
        [strongSelf.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        [strongSelf tableView:strongSelf.tableView didSelectRowAtIndexPath:path];
    }];
    [THMusicPlayController addPreBtnClkBlock:^(THMusicPlayController *playController) {
        __strong typeof(weakSelf) strongSelf = weakSelf ;
        NSIndexPath *path = [strongSelf.tableView indexPathForSelectedRow];
        if (path.row == 0) {
            path = [NSIndexPath indexPathForRow:([strongSelf.musicListDict[ self.musicListDictKeySortedArr[path.section]] musics].count - 1) inSection:path.section];
        }else
        {
        path = [NSIndexPath indexPathForRow:(path.row - 1 )%([strongSelf.musicListDict[ self.musicListDictKeySortedArr[path.section]] musics].count) inSection:path.section];
        }
        [strongSelf.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
        [strongSelf tableView:strongSelf.tableView didSelectRowAtIndexPath:path];
    }];
    [UIApplication sharedApplication].statusBarStyle  = UIStatusBarStyleLightContent ;
}


-  (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.musicListDict = [THMusicListManager musicListDict] ;
    self.musicListDictKeySortedArr = self.musicListDict.allKeys;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.musicListDictKeySortedArr.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.hidenSections containsObject:@(section)]) {
        return  0 ;
    }
    return section == self.musicListDictKeySortedArr.count ? 0 :  [self.musicListDict[self.musicListDictKeySortedArr[section]] musics].count;
}

- (void)addMusicList
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"添加歌单" message:@"请输入名称" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.addListInputNameTF.text.length) {
            [THMusicListManager createMusicListNamed:self.addListInputNameTF.text withMusics:nil];        [THMusicListManager synchronize];
            self.musicListDict = [THMusicListManager musicListDict];
            self.musicListDictKeySortedArr = self.musicListDict.allKeys ;
            [self.tableView reloadData];
        }
        [ac dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.addListInputNameTF = textField ;
    }];
    [ac addAction:confirmAction];
    [ac addAction:cancelAction];
    [self presentViewController:ac animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == self.musicListDictKeySortedArr.count) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_CGFloat, 30)];
        [btn setTitle:@"添加歌单" forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:kMainThemeColor(1) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(addMusicList) forControlEvents:UIControlEventTouchUpInside];
        [btn th_setShaowWithOffset:CGSizeMake(0, 8)];
        btn.backgroundColor = kMainThemeBackgroundColor(1);
        return btn ;
    }
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH_CGFloat, 30)];
    btn.backgroundColor = kMainThemeBackgroundColor(1);
btn.contentHorizontalAlignment  = UIControlContentHorizontalAlignmentLeft;
    [btn setTitle: [NSString stringWithFormat:@"      MusicList    :        %@" ,self.musicListDictKeySortedArr[section]] forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setTitleColor:kMainThemeColor(1) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(foldRow:) forControlEvents:UIControlEventTouchUpInside];
    [btn th_setShaowWithOffset:CGSizeMake(0, 8)];
    btn.titleLabel.textAlignment = NSTextAlignmentLeft ;
    btn.tag = section ;
    return btn ;
}

- (void)foldRow:(UIButton *)sender
{
    
    if ([self.musicListDict[self.musicListDictKeySortedArr[sender.tag]] musics].count) {
    if( self.musicListDictKeySortedArr.count > sender.tag ) {
        if ([self.hidenSections containsObject:@(sender.tag)]) {
            [self.hidenSections removeObject:@(sender.tag)];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationNone];
        }else
        {
            [self.hidenSections addObject:@(sender.tag)];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    }else
    {
    
    NSString *msg  = nil ;
  if(  self.musicListDictKeySortedArr.count > sender.tag )
  {
      msg =  [self.musicListDict[self.musicListDictKeySortedArr[sender.tag]] musics].count ? @"添加歌曲" : @"当前歌单没有歌曲,要去添加吗"  ;
  }else{
      msg = @"当前歌单没有歌曲,要去添加吗";
  }


        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"去添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [THMusicListManager setCurrentOpretedList:self.musicListDict[self.musicListDictKeySortedArr[sender.tag]]];
            [self presentViewController:[THSearchVC new] animated:YES completion:nil];
            [ac dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"算了,不去了" style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:confirmAction];
        [ac addAction:cancelAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    THMusicList *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
     THMusicModel *model = [self.musicListDict[self.musicListDictKeySortedArr[indexPath.section]] musics][indexPath.row];
    cell.music = model ;
      return cell;
}
- (void)cellRightSwipClk:(UISwipeGestureRecognizer *)swip
{
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
        NSIndexPath *indexPath  = self.currentEditIndexPath ;
        self.currentEditIndexPath = nil ;
        if(indexPath != nil){
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            self.tableView.editing = NO ;
    }
    }
}

    
- (void)cellLeftSwipClk:(UISwipeGestureRecognizer *)swip
{
    
    if (swip.direction == UISwipeGestureRecognizerDirectionLeft ) {
      self.currentEditIndexPath =  [self.tableView indexPathForCell:(UITableViewCell *) swip.view];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentEditIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.tableView.editing = YES ;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.currentEditIndexPath] == NSOrderedSame) {
        return YES ;
    }
    return  NO ;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [THMusicListManager synchronize];
    THMusicListModel *musicList = self.musicListDict[self.musicListDictKeySortedArr[indexPath.section]];
    THMusicModel *model = musicList.musics[indexPath.row];

    self.tabBarController.tabBar.hidden = NO ;
    [THMusicPlayController PlayMusic:model showInView:self.view.window usingDefaultBar:YES];
 [THMusicPlayController setTitle:[NSString stringWithFormat:@"%@\n%@",model.songname,model.singername] controlBarClkCallback:^( ) {
     [[NSNotificationCenter defaultCenter] postNotificationName:kTabbarControllerShouldShowPlayerViewNotificationName object:nil userInfo:@{kTabbarControllerShouldShowPlayerViewKey : @YES }];

 }];

    [THMusicPlayController setControlBarIcon:[UIImage imageNamed:@"placeHolder"]];
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:model.singer.image] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [THMusicPlayController setControlBarIcon:image];
    }];
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.currentEditIndexPath compare:indexPath] == NSOrderedSame) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        }];
        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"添加" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        }];
        return @[action , action1];
        
    }
    return  nil ;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  nil ;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert ;
}

@end
