//
//  OpenCenter.m
//  orange
//
//  Created by 谢家欣 on 15/6/8.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "OpenCenter.h"
#import "UserViewController.h"
#import "EntityViewController.h"
#import "NoteViewController.h"
#import "CategoryViewController.h"
#import "TagViewController.h"
#import "WebViewController.h"

#import "AppDelegate.h"

@interface OpenCenter ()

@property (strong, nonatomic) UIViewController * controller;

@end

@implementation OpenCenter

DEFINE_SINGLETON_FOR_CLASS(OpenCenter);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _controller = [[UIApplication sharedApplication] keyWindow].rootViewController;
    }
    return self;
}

- (void)openUser:(GKUser *)user
{
    UserViewController * VC = [[UserViewController alloc]init];
    VC.user = user;
    [kAppDelegate.activeVC.navigationController pushViewController:VC animated:YES];
}

- (void)openEntity:(GKEntity *)entity
{
    EntityViewController * vc = [[EntityViewController alloc] initWithEntity:entity];
    [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
    //    [controller.navigationController pushViewController:vc animated:YES];
}

- (void)openCategory:(GKEntityCategory *)category
{
    CategoryViewController *vc = [[CategoryViewController alloc] init];
    vc.category = category;
    //    [controller.navigationController pushViewController:vc animated:YES];
    [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
}

- (void)openNoteComment:(GKNote *)note
{
    NoteViewController * VC = [[NoteViewController alloc]init];
    VC.note = note;
    [kAppDelegate.activeVC.navigationController pushViewController:VC animated:YES];
}

- (void)openTagWithName:(NSString *)tname User:(GKUser *)user
{
    TagViewController * vc = [[TagViewController alloc]init];
    vc.tagName = tname;
    vc.user = user;
//    vc.user = self.note.creator;
    if (kAppDelegate.activeVC.navigationController) {
        [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)openWebWithURL:(NSURL *)url
{
    WebViewController * vc = [[WebViewController alloc] initWithURL:url];
    [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
}

@end