//
//  THSearchVC.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/23.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THSearchVC.h"

#import "THSearchBar.h"
#import "THNetWorkManager.h"

#import "THMusicModel.h"
#import "THSingerModel.h"

#import "UIImageView+WebCache.h"
#import "THMusicListManager.h"
#import "THMusicListModel.h"
#import "MBProgressHUD+Show.h"
static NSString *const reuseId = @"reuseCellId";
@interface THSearchVC ()

@property (nonatomic,weak) THSearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray<THMusicModel *> *musics;
@property (nonatomic,strong) THMusicListModel *currentOperatedList;

@end

@implementation THSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    self.automaticallyAdjustsScrollViewInsets = NO ;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    self.tableView.bounces = NO ;
    [self configBackImageView];
}

- (void)configBackImageView
{
    UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.image = [UIImage imageNamed:@"placeHoder"];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = image ;
}


- (THSearchBar *)configNavigationBar
{
    THSearchBar *searchBar = [[THSearchBar alloc] initWithFrame:CGRectMake(0 , 0, SCREEN_WIDTH_CGFloat, 64)];
    [searchBar setBackCallback:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    searchBar.title = @"搜索" ;
    [searchBar setSearchStartCallback:^(UITextField *textField, NSString *textForSearch) {
        [THNetWorkManager searchMusicsWithName:textForSearch respondRange:NSMakeRange(0, 20) completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"%@" ,error);
                return ;
            }
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([dict.allKeys containsObject:@"data"]) {
                dict =   dict[@"data"] ;
            }
            
            NSArray *arr = dict[@"data"];
            if ([dict.allKeys containsObject:@"data"]) {
                arr =   dict[@"data"] ;
            }
            
            [arr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
                [self.musics addObject:[THMusicModel musicModelWithDict:dict]];
            }];
            
            THSafeUpdateUIUsingBlock([self.tableView reloadData];);
            
        }];
    }];
    self.searchBar = searchBar ;
    return searchBar ;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO ;
    self.currentOperatedList = [THMusicListManager curentOpretedList];
 }

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musics.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64 ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self configNavigationBar];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.searchBar.searching) {
        self.searchBar.searching = NO ;
    }
    
    if (![self.currentOperatedList.musics containsObject:self.musics[indexPath.row]]) {
        THMusicModel *model = self.musics[indexPath.row];
        NSString *listName = [self.currentOperatedList.listName copy];
        [THMusicListManager loadMusicAddressWithHash:model.HASH inMusicListNamed:self.currentOperatedList.listName];

        NSString *singerIconUrl = [THUserDefault_InstanceOfNSUserDefaults valueForKey:model.singername] ;
        if  (!singerIconUrl) {
            [THNetWorkManager searchSingerInfoWithName:model.singername respondRange:NSMakeRange(0, 1) completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"%@" ,error);
                    return ;
                }
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                NSString *status = dict[@"status"];
                if ([status isEqualToString:@"failed"])
                {
                    return ;
                }
                NSString *iconUrl = dict[@"data"][@"image"] ;
                if (iconUrl.length) {
                    [THUserDefault_InstanceOfNSUserDefaults setObject:iconUrl forKey:model.singername];
                    [[THMusicListManager getMusicListNamed:listName].musics enumerateObjectsUsingBlock:^(THMusicModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.singername isEqualToString:model.singername]) {
                            obj.singer.image = iconUrl;
                        }
                    }];
                }
            }];
        }else
        {
            [self.musics[indexPath.row] singer].image = singerIconUrl ;
        }
        [self.currentOperatedList.musics addObject:self.musics[indexPath.row]];
        [THMusicListManager synchronize];
        [MBProgressHUD showErrorWithText:@"添加成功"];

    }else
    {
        [MBProgressHUD showErrorWithText:@"您已添加过此歌曲"];
    }

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
        cell.backgroundView = [UIView new];
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    THMusicModel *model = self.musics[indexPath.row];
    cell.textLabel.text = model.songname  ;
    cell.detailTextLabel.text =  model.singername ;
    
    return cell;
}

- (NSMutableArray<THMusicModel *> *)musics
{
    if (!_musics) {
        _musics = [NSMutableArray array];
    }
    return  _musics ;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}



@end
