//
//  HomeController.m
//  orange
//
//  Created by 谢家欣 on 15/9/7.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "HomeController.h"
#import "ArticleCell.h"
#import "HomeEntityCell.h"

#import "DiscoverBannerView.h"
#import "WebViewController.h"

@interface HomeController () <DiscoverBannerViewDelegate>

@property (strong, nonatomic) UICollectionView * collectionView;
@property (strong, nonatomic) NSArray * bannerArray;
@property (strong, nonatomic) NSMutableArray * articleArray;
@property (strong, nonatomic) NSMutableArray * entityArray;
@end

@implementation HomeController

static NSString * ArticleIdentifier = @"HomeArticleCell";
static NSString * EntityIdentifier = @"EntityCell";
static NSString * BannerIdentifier = @"BannerView";

#pragma mark - init View
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //        layout.parallaxHeaderAlwaysOnTop = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0., 0., kScreenWidth, kScreenHeight) collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColorFromRGB(0xf8f8f8);
    }
    return _collectionView;
}

#pragma mark - get Data
- (void)refresh
{
    [API getHomeWithSuccess:^(NSArray *banners, NSArray *articles, NSArray *entities) {
        self.bannerArray = banners;
        self.articleArray = [NSMutableArray arrayWithArray:articles];
        self.entityArray = [NSMutableArray arrayWithArray:entities];
        [self.collectionView reloadData];
        [self.collectionView.pullToRefreshView stopAnimating];
    } failure:^(NSInteger stateCode) {
        [self.collectionView.pullToRefreshView stopAnimating];
    }];
}

- (void)loadView
{
    self.view = self.collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[DiscoverBannerView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:BannerIdentifier];
    
    [self.collectionView registerClass:[ArticleCell class] forCellWithReuseIdentifier:ArticleIdentifier];
    
    [self.collectionView registerClass:[HomeEntityCell class] forCellWithReuseIdentifier:EntityIdentifier];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - Fixed SVPullToRefresh in ios7 navigation bar translucent
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    __weak __typeof(&*self)weakSelf = self;
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf refresh];
    }];
    
//    [self.collectionView addInfiniteScrollingWithActionHandler:^{
//        [weakSelf loadMore];
//    }];
//    
//    if (self.articleArray.count == 0)
//    {
        [self.collectionView triggerPullToRefresh];
//    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = self.articleArray.count;
            break;
        case 1:
            count = self.entityArray.count;
            break;
        default:
        
            break;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
        {
            HomeEntityCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:EntityIdentifier forIndexPath:indexPath];
            cell.entity = [self.entityArray objectAtIndex:indexPath.row];
            return cell;
        }
            break;
            
        default:
        {
            ArticleCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ArticleIdentifier forIndexPath:indexPath];
            cell.article = [self.articleArray objectAtIndex:indexPath.row];
            return cell;
        }
            break;
    }

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * reuseableview = [UICollectionReusableView new];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        DiscoverBannerView * bannerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:BannerIdentifier forIndexPath:indexPath];
        bannerView.bannerArray = self.bannerArray;
        bannerView.delegate = self;
        if (self.bannerArray.count == 0) {
            bannerView.hidden = YES;
        }
        else
        {
            bannerView.hidden = NO;
        }
        return bannerView;
    }
    
    return reuseableview;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(0, 0);
    switch (indexPath.section) {
        case 0:
            cellSize = CGSizeMake(kScreenWidth, 117);
            break;
        case 1:
            cellSize = CGSizeMake(kScreenWidth, 180.);
            break;
        default:
            break;
    }
    
    return cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0., 0., 5, 0.);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    CGSize headerSize = CGSizeMake(0, 0);
    switch (section) {
        case 0:
            headerSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame), 150.f*kScreenWidth/320);
            break;
//        case 1:
//            headerSize = CGSizeMake(kScreenWidth, 155.);
//            
//            break;
//        default:
//            headerSize = CGSizeMake(kScreenWidth, 44.);
//            break;
    }
    return headerSize;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - <DiscoverBannerViewDelegate>
- (void)TapBannerImageAction:(NSDictionary *)dict
{
    NSString * url = dict[@"url"];
    [AVAnalytics event:@"banner" attributes:@{@"url": url}];
    [MobClick event:@"banner" attributes:@{@"url": url}];
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
            //            GKWebVC * VC = [GKWebVC linksWebViewControllerWithURL:[NSURL URLWithString:url]];
            WebViewController * VC = [[WebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
            return;
        }
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end