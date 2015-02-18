//
//  DiscoverViewController.m
//  orange
//
//  Created by huiter on 15/1/5.
//  Copyright (c) 2015年 sensoro. All rights reserved.
//

#import "DiscoverViewController.h"
#import "HMSegmentedControl.h"
#import "GKAPI.h"
#import "EntityThreeGridCell.h"
#import "CategoryGridCell.h"
#import "GKWebVC.h"
#import "pinyin.h"
#import "PinyinTools.h"

@interface DiscoverViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchDC;
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray * dataArrayForEntity;
@property(nonatomic, strong) NSMutableArray * dataArrayForCategory;
@property(nonatomic, strong) NSMutableArray * dataArrayForArticle;
@property(nonatomic, assign) NSUInteger index;
@property(nonatomic, strong) HMSegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *bannerArray;
@property (nonatomic, strong) UIScrollView *bannerScrollView;
@property (nonatomic, strong) UIPageControl *bannerPageControl;
@property (nonatomic, strong) NSTimer *bannerTimer;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (nonatomic, strong) NSString *keyword;
@end

@implementation DiscoverViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"发现" image:[UIImage imageNamed:@"tabbar_icon_discover"] selectedImage:[[UIImage imageNamed:@"tabbar_icon_discover"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        self.tabBarItem = item;
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.title = @"发现";
        [self configSearchBar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, kStatusBarHeight+kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight - kStatusBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = UIColorFromRGB(0xffffff);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    [self.view addSubview:self.tableView];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, CGRectGetWidth(self.tableView.frame), 150.f*kScreenWidth/320+32)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    // Banner
    _bannerScrollView = [[UIScrollView alloc] init];
    _bannerPageControl = [[UIPageControl alloc] init];
    self.bannerScrollView.frame = CGRectMake(0, 0, headerView.bounds.size.width, headerView.bounds.size.height-32);
    self.bannerScrollView.backgroundColor = [UIColor whiteColor];
    self.bannerScrollView.delegate = self;
    self.bannerScrollView.showsHorizontalScrollIndicator = NO;
    self.bannerScrollView.pagingEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(tapBanner)];
    [self.bannerScrollView addGestureRecognizer:tap];
    [headerView addSubview:self.bannerScrollView];
    
    
    if (!self.segmentedControl) {
        HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 32)];
        [segmentedControl setSectionTitles:@[@"热门商品", @"推荐分类"]];
        [segmentedControl setSelectedSegmentIndex:0 animated:NO];
        [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
        [segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationNone];
        [segmentedControl setTextColor:UIColorFromRGB(0x427ec0)];
        [segmentedControl setSelectedTextColor:UIColorFromRGB(0x427ec0)];
        [segmentedControl setBackgroundColor:UIColorFromRGB(0xe4f0fc)];
        [segmentedControl setSelectionIndicatorColor:UIColorFromRGB(0xcde3fb)];
        [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        segmentedControl.deFrameBottom = headerView.deFrameHeight;
        self.segmentedControl = segmentedControl;
        [headerView addSubview:self.segmentedControl];
    }

    
    self.tableView.tableHeaderView = headerView;
    
    [GKAPI getHomepageWithSuccess:^(NSDictionary *settingDict, NSArray *bannerArray, NSArray *hotCategoryArray, NSArray *hotTagArray) {
        // 过滤可处理的banner类型
        NSMutableArray *showBannerArray = [NSMutableArray array];
        for (NSDictionary *itemDict in bannerArray) {
            NSString *url = [[itemDict objectForKey:@"url"] lowercaseString];
            if ([url hasPrefix:@"guoku://entity"] ||
                [url hasPrefix:@"guoku://category"] ||
                [url hasPrefix:@"guoku://user"] ||
                [url hasPrefix:@"http://"]) {
                [showBannerArray addObject:itemDict];
            }
        }
        self.bannerArray = showBannerArray;
    } failure:nil];
    
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
        [GKAPI getAllCategoryWithSuccess:^(NSArray *fullCategoryGroupArray) {
        
                NSMutableArray *categoryGroupArray = [NSMutableArray array];
                NSMutableArray *allCategoryArray = [NSMutableArray array];
                
                for (NSDictionary *groupDict in fullCategoryGroupArray) {
                    NSArray *categoryArray = groupDict[@"CategoryArray"];
                    
                    NSMutableArray *filteredCategoryArray = [NSMutableArray array];
                    for (GKEntityCategory *category in categoryArray) {
                        [allCategoryArray addObject:category];
                        
                        if (category.status) {
                            [filteredCategoryArray addObject:category];
                        }
                    }
                    NSDictionary *filteredGroupDict = @{@"GroupId"       : groupDict[@"GroupId"],
                                                        @"GroupName"     : groupDict[@"GroupName"],
                                                        @"Status"        : groupDict[@"Status"],
                                                        @"Count"         : @(categoryArray.count),
                                                        @"CategoryArray" : filteredCategoryArray};
                    if ([groupDict[@"Status"] integerValue] > 0) {
                        [categoryGroupArray addObject:filteredGroupDict];
                    }
                }
            
            self.dataArrayForCategory = categoryGroupArray;
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
    
        } failure:^(NSInteger stateCode) {
            [SVProgressHUD showImage:nil status:@"失败"];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
            
        }];
    }
    return;
}
- (void)loadMore
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableView)
    {
        if (self.index == 0) {
            return 1;
        }
        else if (self.index == 1)
        {
            return ceil(self.dataArrayForCategory.count / (CGFloat)1);
        }
        return 0;
    }
    else
    {
        return 1;
    }
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
            return (((NSMutableArray *)[[self.dataArrayForCategory objectAtIndex:section] objectForKey:@"CategoryArray"]).count /(CGFloat)4);
        }
        return 0;
    }
    else
    {
        return (self.filteredArray.count /(CGFloat)4);
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
            static NSString *CellIdentifier = @"CategoryCell";
            CategoryGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[CategoryGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            NSDictionary *groupDict = self.dataArrayForCategory[indexPath.section];
            NSArray *categoryDictArray = [groupDict objectForKey:@"CategoryArray"];
            
            NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
            
            NSUInteger offset = indexPath.row * 4;
            int i = 0;
            for (; offset < categoryDictArray.count ; offset++) {
                [categoryArray addObject:categoryDictArray[offset]];
                i++;
                if (i>=4) {
                    break;
                }
            }
            cell.categoryArray = categoryArray;
            return cell;
        }
        return [[UITableViewCell alloc] init];
    }
    else
    {
        static NSString *CellIdentifier = @"CategoryCell";
        CategoryGridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[CategoryGridCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        

        NSArray *categoryDictArray = self.filteredArray;
        
        NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
        
        NSUInteger offset = indexPath.row * 4;
        int i = 0;
        for (; offset < categoryDictArray.count ; offset++) {
            [categoryArray addObject:categoryDictArray[offset]];
            i++;
            if (i>=4) {
                break;
            }
        }
        cell.categoryArray = categoryArray;
        return cell;
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
            return [CategoryGridCell height];
        }
        return 0;
    }
    else
    {
        return [CategoryGridCell height];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        if (self.index == 1) {
            return 32;
        }
    }
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == self.tableView)
    {
        if(self.index == 1)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, CGRectGetWidth(tableView.frame)-20, 20.f)];
            label.text = [self.dataArrayForCategory[section] valueForKey:@"GroupName"];
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = UIColorFromRGB(0x666666);
            label.font = [UIFont boldSystemFontOfSize:14];
            [label sizeToFit];
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 32)];
            view.backgroundColor = [UIColor whiteColor];
            [view addSubview:label];
            
            return view;
        }
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
            if (self.dataArrayForCategory.count == 0) {
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

#pragma mark - ConfigSearchBar
- (void)configSearchBar
{
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 48.0f)];
    self.searchBar.tintColor = UIColorFromRGB(0x666666);
    
    [self.searchBar setBackgroundImage:[[UIImage imageWithColor:UIColorFromRGB(0xffffff) andSize:CGSizeMake(10, 48)] stretchableImageWithLeftCapWidth:5 topCapHeight:5]  forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xf6f6f6) andSize:CGSizeMake(10, 28)]  forState:UIControlStateNormal];
    self.searchBar.searchTextPositionAdjustment = UIOffsetMake(2.f, 0.f);
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索";

    
    _searchDC = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    self.searchDC.displaysSearchBarInNavigationBar = YES;
    self.searchDC.searchResultsDataSource = self;
    self.searchDC.searchResultsDelegate = self;
    self.searchDC.searchResultsTableView.backgroundColor = UIColorFromRGB(0xffffff);
    self.searchDC.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDC.searchResultsTableView.separatorColor = UIColorFromRGB(0xffffff);
    self.searchDC.searchResultsTableView.tableHeaderView = nil;
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark - Getter And Setter
- (void)setBannerArray:(NSArray *)bannerArray
{
    _bannerArray = bannerArray;
    
    for (UIView *view in self.bannerScrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]] && view.tag == 100) {
            [view removeFromSuperview];
        }
    }
    
    self.bannerScrollView.frame = CGRectMake(7, 7, kScreenWidth-14, 149*kScreenWidth/320-15);
    self.bannerScrollView.backgroundColor = UIColorFromRGB(0xf1f1f1);
    
    [self.bannerArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        NSURL *imageURL = [NSURL URLWithString:[dict valueForKey:@"img"]];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bannerScrollView.frame) * idx, 0.f, CGRectGetWidth(self.bannerScrollView.frame), CGRectGetHeight(self.bannerScrollView.frame))];
        imageView.tag = 100;
        imageView.backgroundColor = UIColorFromRGB(0xf1f1f1);
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView sd_setImageWithURL:imageURL placeholderImage:nil options:SDWebImageRetryFailed];
        [self.bannerScrollView addSubview:imageView];
    }];
    
    self.bannerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bannerScrollView.frame) * self.bannerArray.count, CGRectGetHeight(self.bannerScrollView.frame));
    self.bannerPageControl.currentPage = 0;
    self.bannerPageControl.numberOfPages = self.bannerArray.count;
}

- (void)changeBanner
{
    NSInteger index = fabs(self.bannerScrollView.contentOffset.x) / CGRectGetWidth(self.bannerScrollView.bounds);
    self.bannerPageControl.currentPage = (index + 1) % self.bannerArray.count;
    [self.bannerScrollView setContentOffset:CGPointMake(self.bannerPageControl.currentPage * CGRectGetWidth(self.bannerScrollView.bounds), 0.f) animated:YES];
}

- (void)tapBanner
{
    
    NSInteger index = self.bannerPageControl.currentPage;
    NSDictionary *dict = (NSDictionary *)self.bannerArray[index];
    NSString *url = [dict valueForKey:@"url"];
    if ([url hasPrefix:@"http://"]) {
        if (k_isLogin) {
            NSRange range = [url rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                url = [url stringByAppendingString:[NSString stringWithFormat:@"&session=%@",[Passport sharedInstance].session]];
            }
            else
            {
                url = [url stringByAppendingString:[NSString stringWithFormat:@"?session=%@",[Passport sharedInstance].session]];
            }
        }
        NSRange range = [url rangeOfString:@"out_link"];
        if (range.location == NSNotFound) {
            GKWebVC * VC = [GKWebVC linksWebViewControllerWithURL:[NSURL URLWithString:url]];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
            return;
        }
    }
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.bannerScrollView) {
        // 获取当前页码
        NSInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
        // 设置当前页码
        self.bannerPageControl.currentPage = index;
    }
}


#pragma mark - SearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText length] == 0) {
        return;
    }
    self.keyword = self.searchBar.text;
    self.keyword = [self.keyword stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self handleSearchText:self.keyword];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString * searchText = self.searchBar.text;
    if ([searchText length] == 0) {
        return;
    }
    self.keyword = searchText;
    [self searchButtonAction];
}
- (void)handleSearchText:(NSString *)searchText
{
    self.filteredArray = [NSMutableArray array];
    for (GKEntityCategory *word in kAppDelegate.allCategoryArray) {
        NSString *screenName = word.categoryName;
        if ([PinyinTools ifNameString:screenName SearchString:searchText]) {
            [_filteredArray addObject:word];
        }
    }
    [self.filteredArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO]]];
    
   
    {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
        button.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:UIColorFromRGB(0xcacaca) forState:UIControlStateNormal];
        [button setTitle:[NSString fontAwesomeIconStringForEnum:FAAngleRight] forState:UIControlStateNormal];
        button.deFrameRight = kScreenWidth -20;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(searchButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[NSString stringWithFormat:@"直接搜索 %@ ",searchText] forState:UIControlStateNormal];
        self.searchDC.searchResultsTableView.tableHeaderView = button;
    }
    [self.searchDC.searchResultsTableView reloadData];
    
}
- (void)searchButtonAction
{
    /**/
}

@end
