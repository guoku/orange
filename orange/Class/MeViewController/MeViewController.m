//
//  MeViewController.m
//  orange
//
//  Created by huiter on 15/1/5.
//  Copyright (c) 2015年 sensoro. All rights reserved.
//

#import "MeViewController.h"
#import "GKAPI.h"
#import "HMSegmentedControl.h"
#import "EntityThreeGridCell.h"

@interface MeViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray * dataArrayForEntity;
@property(nonatomic, strong) NSMutableArray * dataArrayForNote;
@property(nonatomic, strong) NSMutableArray * dataArrayForTag;
@property(nonatomic, strong) GKUser *user;
@property(nonatomic, assign) NSUInteger index;


@end

@implementation MeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"我" image:[UIImage imageNamed:@"me"] selectedImage:[UIImage imageNamed:@"me"]];
        
        self.tabBarItem = item;
        
        self.title = @"我";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenWidth, kScreenHeight-kNavigationBarHeight - kStatusBarHeight -kTabBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = UIColorFromRGB(0xffffff);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.tableView];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refresh];
    }];
    
    /*
     [self.tableView addInfiniteScrollingWithActionHandler:^{
     [weakSelf loadMore];
     }];
     */
    
    
    [self.tableView.pullToRefreshView startAnimating];
    [self refresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.user = [Passport sharedInstance].user;
    [self configHeaderView];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Data
- (void)refresh
{
    if (self.index == 0) {
        [GKAPI getHotEntityListWithType:@"weekly" success:^(NSArray *dataArray) {
            self.dataArrayForEntity = [NSMutableArray arrayWithArray:dataArray];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
        } failure:^(NSInteger stateCode) {
            [SVProgressHUD showImage:nil status:@"失败"];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
        }];
    }
    else if (self.index == 1)
    {

    }
    return;
}
- (void)loadMore
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.index == 0) {
        return 1;
    }
    else if (self.index == 1)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        if (self.index == 0) {
            return ceil(self.dataArrayForEntity.count / (CGFloat)3);
        }
        else if (self.index == 1)
        {
            return ceil(self.dataArrayForNote.count / (CGFloat)3);
        }
        return 0;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        if (self.index == 0) {
            static NSString *CellIdentifier = @"EntityCell";
            EntityThreeGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[EntityThreeGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            NSArray *entityArray = self.dataArrayForEntity;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSUInteger offset = indexPath.row * 3;
            for (NSUInteger i = 0; i < 3 && offset < entityArray.count; i++) {
                [array addObject:entityArray[offset++]];
            }
            
            cell.entityArray = array;
            
            return cell;
        }
        else if (self.index == 1)
        {
            return [[UITableViewCell alloc] init];
        }
        return [[UITableViewCell alloc] init];
    }
    else
    {
        return [[UITableViewCell alloc] init];
    }
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        if (self.index == 0) {
            return [EntityThreeGridCell height];
        }
        else if (self.index == 1)
        {
            return 80;
        }
        return 0;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        return 32;
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
        [segmentedControl setSectionTitles:@[[NSString stringWithFormat:@"喜爱 %ld",self.user.likeCount], [NSString stringWithFormat:@"点评 %ld",self.user.noteCount],[NSString stringWithFormat:@"标签 %ld",self.user.tagCount]]];
        [segmentedControl setSelectedSegmentIndex:0 animated:NO];
        [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
        [segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationNone];
        [segmentedControl setTextColor:UIColorFromRGB(0x427ec0)];
        [segmentedControl setSelectedTextColor:UIColorFromRGB(0x427ec0)];
        [segmentedControl setBackgroundColor:UIColorFromRGB(0xe4f0fc)];
        [segmentedControl setSelectionIndicatorColor:UIColorFromRGB(0xcde3fb)];
        [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        return segmentedControl;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


#pragma mark - HMSegmentedControl
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    self.index = index;
    [self.tableView reloadData];
    switch (index) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            if (self.dataArrayForNote.count == 0) {
                [self.tableView.pullToRefreshView startAnimating];
                [self refresh];
            }
        }
            break;
        case 2:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)configHeaderView
{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 270)];
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(7.f, 7.f, 100, 100)];
    image.contentMode = UIViewContentModeScaleAspectFit;
    image.center = CGPointMake(kScreenWidth/2, 80);
    image.layer.cornerRadius = 50;
    image.layer.masksToBounds = YES;
    image.backgroundColor = UIColorFromRGB(0xffffff);
    [image sd_setImageWithURL:self.user.avatarURL];
    [view addSubview:image];
    

    UILabel * nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 20.f, 320.f, 25.f)];
    nicknameLabel.backgroundColor = [UIColor clearColor];
    nicknameLabel.font = [UIFont boldSystemFontOfSize:18];
    nicknameLabel.textAlignment = NSTextAlignmentCenter;
    nicknameLabel.textColor = UIColorFromRGB(0x555555);
    nicknameLabel.text = self.user.nickname;
    nicknameLabel.adjustsFontSizeToFitWidth = YES;
    [nicknameLabel sizeToFit];
    nicknameLabel.center = image.center;
    nicknameLabel.deFrameTop = image.deFrameBottom+15;
    nicknameLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:nicknameLabel];
    

    UIImageView * gender = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 14, 14)];
    gender.center = CGPointMake(nicknameLabel.deFrameRight+10 ,nicknameLabel.center.y);
    if ([self.user.gender isEqualToString:@"M"]) {
        gender.image = [UIImage imageNamed:@"user_icon_male.png"];
    }
    else if([self.user.gender isEqualToString:@"F"]) {
        gender.image = [UIImage imageNamed:@"user_icon_famale.png"];
    }
    else
    {
        gender.image = nil;
    }
    [view addSubview:gender];
    

    UILabel * bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 20.f, 260.f, 30.f)];
    bioLabel.numberOfLines = 0;
    bioLabel.backgroundColor = [UIColor clearColor];
    bioLabel.font = [UIFont systemFontOfSize:12];
    bioLabel.textAlignment = NSTextAlignmentCenter;
    bioLabel.textColor = UIColorFromRGB(0x999999);
    bioLabel.text = self.user.bio;
    bioLabel.center = image.center;
    bioLabel.backgroundColor = [UIColor clearColor];
    if ([self.user.bio isEqualToString:@""]||!self.user.bio) {
        bioLabel.deFrameHeight = 0;
        bioLabel.deFrameTop = nicknameLabel.deFrameBottom+0;
    }
    else
    {
        bioLabel.deFrameTop = nicknameLabel.deFrameBottom+10;
        bioLabel.deFrameHeight = 30;
    }
    [view addSubview:bioLabel];
    
   
    
    UIButton * friendButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth/2-10, 20)];
    [friendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [friendButton setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
    //[friendButton addTarget:self action:@selector() forControlEvents:UIControlEventTouchUpInside];
    [friendButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [friendButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [friendButton setTitle:[NSString stringWithFormat:@"%ld 关注",_user.followingCount] forState:UIControlStateNormal];
    if (self.user.userId == [Passport sharedInstance].user.userId) {
        friendButton.deFrameTop = bioLabel.deFrameBottom+10;
    }
    else
    {
        friendButton.deFrameTop = bioLabel.deFrameBottom+10;
    }
    [view addSubview:friendButton];
    

    UIButton * fanButton = [[UIButton alloc]initWithFrame:CGRectMake( kScreenWidth/2+10, 0, kScreenWidth -10, 20)];
    [fanButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [fanButton setTitleColor:UIColorFromRGB(0x777777) forState:UIControlStateNormal];
    //[fanButton addTarget:self action:@selector(goUserFanList) forControlEvents:UIControlEventTouchUpInside];
    [fanButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [fanButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    fanButton.deFrameTop = friendButton.deFrameTop;
    [fanButton setTitle:[NSString stringWithFormat:@"%ld 粉丝",_user.fanCount] forState:UIControlStateNormal];
    [view addSubview:fanButton];
    
    UIView * V = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 20)];
    V.backgroundColor = UIColorFromRGB(0xc8c8c8);
    V.center = CGPointMake(kScreenWidth/2, fanButton.center.y);
    [view addSubview:V];
    
    self.tableView.tableHeaderView = view;
}

@end
