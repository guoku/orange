//
//  SettingViewController.h
//  emojiii
//
//  Created by huiter on 14/12/10.
//  Copyright (c) 2014年 sensoro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView * tableView;

@end
