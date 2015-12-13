//
//  AuthController.m
//  orange
//
//  Created by huiter on 15/12/10.
//  Copyright © 2015年 guoku.com. All rights reserved.
//

#import "AuthController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface AuthController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property(strong,nonatomic) LoginViewController * loginVC;
@property(strong,nonatomic) RegisterViewController * registerVC;

@property (strong, nonatomic) UIPageViewController * thePageViewController;
@property (assign, nonatomic) NSInteger index;

@end

@implementation AuthController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Present 后，底层页面还隐藏。这里对屏幕截图进行效果拟补。*/
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScreenWidth, kScreenHeight), YES, 1);
    [kAppDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView * v = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    v.image = img;
    [self.view addSubview:v];
    [self.view sendSubviewToBack:v];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (LoginViewController *)loginVC
{
    if (!_loginVC) {
        _loginVC = [[LoginViewController alloc] init];
        _loginVC.authController = self;
    }
    return _loginVC;
}

- (RegisterViewController *)registerVC
{
    if (!_registerVC) {
        _registerVC = [[RegisterViewController alloc] init];
        _registerVC.authController = self;
    }
    return _registerVC;
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
    self.view.backgroundColor = [UIColor clearColor];
         [self addChildViewController:self.thePageViewController];
    
    self.thePageViewController.view.frame = CGRectMake(0,0, kScreenWidth,  kScreenHeight);
    
    [self.thePageViewController setViewControllers:@[self.loginVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self.view addSubview:self.thePageViewController.view];
    
}

#pragma mark - <UIPageViewControllerDataSource>
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[RegisterViewController class]]) {
        return self.loginVC;
    }

    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    if ([viewController isKindOfClass:[LoginViewController class]]) {
        return self.registerVC;
    }


    return nil;
}

#pragma mark - <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.index = 0;
    if (completed) {
        if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[LoginViewController class]]) {
            self.index = 0;
        }
        if ([[pageViewController.viewControllers objectAtIndex:0] isKindOfClass:[RegisterViewController class]]) {
            self.index = 1;
        }
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


- (void)setSelectedWithType:(NSString *)type
{
    if ([type isEqualToString:@"login"]) {
        [self.thePageViewController setViewControllers:@[self.loginVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    else if ([type isEqualToString:@"register"]) {
        [self.thePageViewController setViewControllers:@[self.registerVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}



@end
