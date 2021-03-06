//
//  OpenCenter.m
//  orange
//
//  Created by 谢家欣 on 15/6/8.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "OpenCenter.h"
#import "UserViewController.h"
#import "AuthUserViewController.h"
#import "EntityViewController.h"
#import "NoteViewController.h"
#import "SubCategoryEntityController.h"
#import "TagViewController.h"
#import "TagArticlesController.h"

#import "WebViewController.h"
#import "ArticleWebViewController.h"
//#import "AppDelegate.h"

#import "AuthController.h"

#import "MainController.h"

@interface OpenCenter ()

@property (strong, nonatomic) UIViewController  *controller;
@property (strong, nonatomic) UIViewController  *topController;

@end

@implementation OpenCenter

DEFINE_SINGLETON_FOR_CLASS(OpenCenter);

- (UIViewController *)controller
{
    if (!_controller) {
        _controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
    }
    return _controller;
}

- (UIViewController *)topController
{
    DDLogInfo(@"controller %@", self.controller);
    UITabBarController *tabbarController;
    
    if (IS_IPHONE) {
        if ([self.controller isKindOfClass:[UITabBarController class]]) {
            tabbarController    = (UITabBarController *)self.controller;
            UINavigationController *nav = tabbarController.selectedViewController;
            _topController  = nav.viewControllers.lastObject;
        }
    } else {
        tabbarController    = (UITabBarController *)[self.controller.childViewControllers lastObject];
        UINavigationController *nav = tabbarController.selectedViewController;
        _topController  = nav.viewControllers.lastObject;
    }
    return _topController;
}

- (void)openAuthPage
{
    [self openAuthPageWithSuccess:nil];
}

- (void)openAuthPageWithSuccess:(void (^)())success
{
    AuthController * vc = [[AuthController alloc] init];
    vc.successBlock = success;

    
    if (IS_IPHONE) {
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self.controller presentViewController:nav animated:YES completion:nil];
    } else {
        [self.controller addChildViewController:vc];
        [self.controller.view addSubview:vc.view];
        
    }
}

- (void)openAuthUser:(GKUser *)user
{
    AuthUserViewController * vc = [[AuthUserViewController alloc] initWithUser:user];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    
//    [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
    [self.topController.navigationController pushViewController:vc animated:YES];
}

- (void)openNormalUser:(GKUser *)user
{
    UserViewController * VC = [[UserViewController alloc]init];
    VC.user = user;
    if (IS_IPHONE) VC.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:VC animated:YES];
}


- (void)openWithController:(UIViewController *)controller User:(GKUser *)user
{
    UserViewController * VC = [[UserViewController alloc]init];
    VC.user = user;
    if (IS_IPHONE) VC.hidesBottomBarWhenPushed = YES;
//    [controller.navigationController pushViewController:VC animated:YES];
    [self.topController.navigationController pushViewController:VC animated:YES];
}

- (void)openUser:(GKUser *)user
{
    if (!user.nickname)
    {
        [API getUserDetailWithUserId:user.userId success:^(GKUser *user, NSArray *lastLikeEntities, NSArray *lastNotes, NSArray *lastArticles) {
            
            user.authorized_author ? [self openAuthUser:user] : [self openNormalUser:user];

        } failure:^(NSInteger stateCode) {
            [self openNormalUser:user];
        }];
    }
    else
    {
        user.authorized_author ? [self openAuthUser:user] : [self openNormalUser:user];

    }
}

- (void)openEntity:(GKEntity *)entity
{
    [self openEntity:entity hideButtomBar:NO];
}

- (void)openEntity:(GKEntity *)entity hideButtomBar:(BOOL)hide
{
    EntityViewController * vc = [[EntityViewController alloc] initWithEntity:entity];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:vc animated:YES];
}

- (void)openCategory:(GKEntityCategory *)category
{
    SubCategoryEntityController *vc = [[SubCategoryEntityController alloc] initWithSubCategory:category];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:vc animated:YES];
}

- (void)openNoteComment:(GKNote *)note
{
    NoteViewController * VC = [[NoteViewController alloc] init];
    VC.note = note;
    [self.topController.navigationController pushViewController:VC animated:YES];
}

#pragma mark - tag viewcontroller
- (void)openTagWithName:(NSString *)tname User:(GKUser *)user
{
    [self openTagWithName:tname User:user Controller:nil];
}

- (void)openTagWithName:(NSString *)tname User:(GKUser *)user Controller:(UIViewController *)controller
{
    TagViewController * vc = [[TagViewController alloc] init];
    vc.tagName = tname;
    DDLogInfo(@"tag tag user %@", user);
    vc.user = user;
    if (controller) {
        [controller.navigationController pushViewController:vc animated:YES];
    } else {
        [self.topController.navigationController pushViewController:vc animated:YES];
    }
}

- (void)openArticleTagWithName:(NSString *)name
{
    TagArticlesController * vc = [[TagArticlesController alloc] initWithTagName:name];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
//    if (kAppDelegate.activeVC.navigationController) {
    [self.topController.navigationController pushViewController:vc animated:YES];
//    }
}

- (void)openStoreWithURL:(NSURL *)url
{
    WebViewController   *vc = [[WebViewController alloc] initWithURL:url showHTMLTitle:YES];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:vc animated:YES];
}


#pragma mark - open webview
- (void)openWebWithURL:(NSURL *)url
{
    WebViewController * vc = [[WebViewController alloc] initWithURL:url];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:vc animated:YES];
}


- (void)openArticleWebWithArticle:(GKArticle *)article
{
    ArticleWebViewController * vc = [[ArticleWebViewController alloc] initWithArticle:article];
    if (IS_IPHONE) vc.hidesBottomBarWhenPushed = YES;
    [self.topController.navigationController pushViewController:vc animated:YES];
}


@end
