//
//  SelectionController.m
//  orange
//
//  Created by 谢家欣 on 15/6/26.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "SelectionController.h"
#import "HMSegmentedControl.h"
#import "HomeController.h"
#import "SelectionViewController.h"
#import "ArticlesController.h"


@interface SelectionController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController * thePageViewController;
@property (strong, nonatomic) HMSegmentedControl *segmentedControl;
@property (assign, nonatomic) NSInteger index;

@property (strong, nonatomic) HomeController * homeVC;
@property (strong, nonatomic) SelectionViewController * entityVC;
@property (strong, nonatomic) ArticlesController * articleVC;

@end

@implementation SelectionController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle: @"" image:[UIImage imageNamed:@"tabbar_icon_selection"] selectedImage:[[UIImage imageNamed:@"tabbar_icon_selection"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        self.tabBarItem = item;
        self.index = 0;
    }
    return self;
}

#pragma mark - init view
- (HMSegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-40, 36)];
        
        [_segmentedControl setSectionTitles:@[NSLocalizedStringFromTable(@"selection-nav-recommend", kLocalizedFile, nil), NSLocalizedStringFromTable(@"selection-nav-entity", kLocalizedFile, nil),NSLocalizedStringFromTable(@"selection-nav-article", kLocalizedFile, nil)]];
        [_segmentedControl setSelectedSegmentIndex:0 animated:NO];
        [_segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleTextWidthStripe];
        [_segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
        [_segmentedControl setTextColor:UIColorFromRGB(0x9d9e9f)];
        [_segmentedControl setSelectedTextColor:UIColorFromRGB(0xFF1F77)];
        [_segmentedControl setBackgroundColor:[UIColor clearColor]];
        [_segmentedControl setSelectionIndicatorColor:UIColorFromRGB(0xFF1F77)];
        [_segmentedControl setSelectionIndicatorHeight:2];
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        [_segmentedControl setTag:2];
    }
    return _segmentedControl;
}

- (HomeController *)homeVC
{
    if (!_homeVC) {
        _homeVC = [[HomeController alloc] init];
    }
    return _homeVC;
}

- (SelectionViewController *)entityVC
{
    if (!_entityVC) {
        _entityVC = [[SelectionViewController alloc] init];
    }
    return _entityVC;
}

- (ArticlesController *)articleVC
{
    if (!_articleVC) {
        _articleVC = [[ArticlesController alloc] init];
    }
    return _articleVC;
}

- (UIPageViewController *)thePageViewController
{
    if (!_thePageViewController) {
        _thePageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _thePageViewController.dataSource = self;
        _thePageViewController.delegate = self;
    }
    return _thePageViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.title = NSLocalizedStringFromTable(@"Selection", kLocalizedFile, nil);
    
    self.navigationItem.titleView = self.segmentedControl;

    [self addChildViewController:self.thePageViewController];
    
    self.thePageViewController.view.frame = CGRectMake(0, 0, kScreenWidth,  kScreenHeight);

    [self.thePageViewController setViewControllers:@[self.homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    
    [self.view insertSubview:self.thePageViewController.view belowSubview:self.segmentedControl];
}

#pragma mark - <UIPageViewControllerDataSource>
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 3;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[ArticlesController class]]) {
        return self.entityVC;
    }
    if ([viewController isKindOfClass:[SelectionViewController class]]) {
        return self.homeVC;
    }
    if ([viewController isKindOfClass:[HomeController class]]) {
        //return self.articleVC;
    }

    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
     if ([viewController isKindOfClass:[ArticlesController class]]) {
         //return self.homeVC;
     }
     if ([viewController isKindOfClass:[HomeController class]]) {
         return self.entityVC;
     }
     if ([viewController isKindOfClass:[SelectionViewController class]]) {
         return self.articleVC;
     }
     return nil;
}

#pragma mark - <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.index = 0;
    if (completed) {
        if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[HomeController class]]) {
            self.index = 0;
        }
        if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[SelectionViewController class]]) {
            self.index = 1;
        }
        if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[ArticlesController class]]) {
            self.index = 2;
        }
        
        [self.segmentedControl setSelectedSegmentIndex:self.index animated:YES];
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation {

    UIViewController *currentViewController = [self.thePageViewController.viewControllers objectAtIndex:0];

    NSArray * view_controllers = [NSArray arrayWithObjects:currentViewController, nil];
    [self.thePageViewController setViewControllers:view_controllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.thePageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark -
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{

    self.index = segmentedControl.selectedSegmentIndex;
    
    if (segmentedControl.selectedSegmentIndex == 0){
        [self.thePageViewController setViewControllers:@[self.homeVC] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    
    if (segmentedControl.selectedSegmentIndex == 1){
        [self.thePageViewController setViewControllers:@[self.entityVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    if (segmentedControl.selectedSegmentIndex == 2){
        [self.thePageViewController setViewControllers:@[self.articleVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
}
@end