//
//  THVideoDisplayVC.m
//  THMediaPlayeCacher
//
//  Created by litianhao on 16/6/30.
//  Copyright © 2016年 litianhao. All rights reserved.
//

#import "THVideoDisplayVC.h"
#import "THVideoDisplayCell.h"
#import "THVideoModel.h"
@interface THVideoDisplayVC ()
@end

@implementation THVideoDisplayVC

- (THVIdeoViewModel *)videoViewModel
{
    if (!_videoViewModel) {
        _videoViewModel = [[THVIdeoViewModel alloc] init];
        THVideoModel *model = [[THVideoModel alloc] init];
        model.love = @"999";
        model.name = @"百思姐";
        model.text = @"精彩电影剪辑";
        model.create_time = @"2016-06-30 07:58:00";
        model.profile_image = @"http://b.hiphotos.baidu.com/image/pic/item/d788d43f8794a4c274c8110d0bf41bd5ad6e3928.jpg";
        model.video_uri = @"http://zyvideo1.oss-cn-qingdao.aliyuncs.com/zyvd/7c/de/04ec95f4fd42d9d01f63b9683ad0";
        [_videoViewModel.videos addObject:model];
    }
    return _videoViewModel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.videoViewModel.videos.count ==1) {
        __weak typeof(self) weakSelf = self ;

        [self.videoViewModel loadVideoWithPage:1 completion:^{
            __strong typeof(weakSelf) strongSelf = weakSelf ;
            THSafeUpdateUIUsingBlock([strongSelf.tableView reloadData];)
        }];
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"THVideoDisplayCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 200 ;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoViewModel.videos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    THVideoDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.videoViewModel.videos.count - indexPath.row < 5) {
        [self.videoViewModel loadVideoWithPage:self.videoViewModel.page + 1 completion:^{
            [self.tableView  reloadData];
        }];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    THVideoDisplayCell *cell1 =(THVideoDisplayCell *) cell;
    cell1.video = self.videoViewModel.videos[indexPath.row];
}



@end
