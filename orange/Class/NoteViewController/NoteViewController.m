//
//  NoteViewController.m
//  orange
//
//  Created by huiter on 15/2/1.
//  Copyright (c) 2015年 sensoro. All rights reserved.
//

#import "NoteViewController.h"
#import "API.h"
#import "CommentCell.h"
#import "CommentHeaderView.h"
#import "UserViewController.h"
//#import "LoginView.h"
static NSString *CellIdentifier = @"CommentCell";

@interface NoteViewController ()<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, CommentHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property(strong,nonatomic) NSMutableArray * dataArrayForComment;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) CommentHeaderView * headerView;
@property (nonatomic, strong) UIView * footerView;
@end

@implementation NoteViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillShowNotification];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillHideNotification];
//    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardWillChangeFrameNotification];
}

- (CommentHeaderView *)headerView
{
    if (!_headerView) {
        _headerView = [[CommentHeaderView alloc] initWithFrame:IS_IPHONE?CGRectMake(0., 0., kScreenWidth, [CommentHeaderView height:self.note]):CGRectMake(0., 0., kScreenWidth - kTabBarWidth, [CommentHeaderView height:self.note])];
        _headerView.backgroundColor = UIColorFromRGB(0xffffff);
        _headerView.delegate = self;
    }
    return _headerView;
}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:IS_IPHONE?CGRectMake(0., 0., kScreenWidth, 44.):CGRectMake(0., 0., kScreenWidth - kTabBarWidth, 44.)];
        _footerView.backgroundColor = [UIColor clearColor];
        UILabel * footerL = [[UILabel alloc] initWithFrame:IS_IPHONE?CGRectMake(0., 12., kScreenWidth, 20.):CGRectMake(0., 12., kScreenWidth - kTabBarWidth, 20.)];
        footerL.textAlignment = NSTextAlignmentCenter;
        footerL.font = [UIFont systemFontOfSize:14.];
        footerL.textColor = UIColorFromRGB(0x9d9e9f);
        footerL.text = @"暂无评论";
        footerL.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
//        _footerView.backgroundColor = [UIColor redColor];
        [_footerView addSubview:footerL];
    
    }
    return _footerView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    self.title = NSLocalizedStringFromTable(@"comment", kLocalizedFile, nil);
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenWidth, kScreenHeight-kNavigationBarHeight - kStatusBarHeight-kToolBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = UIColorFromRGB(0xfafafa);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.tableView];
    
//    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refresh];
    }];
    
    
    if (!self.inputBar) {
        _inputBar = [[UIView alloc] initWithFrame:IS_IPHONE?CGRectMake(0.f, self.tableView.deFrameBottom, kScreenWidth, kToolBarHeight):CGRectMake(0.f, self.tableView.deFrameBottom, kScreenWidth - kTabBarWidth, kToolBarHeight)];
        self.inputBar.backgroundColor = UIColorFromRGB(0xf1f1f1);
        [self.view addSubview:self.inputBar];
        
        _inputTextField = [[UITextField alloc] initWithFrame:IS_IPHONE?CGRectMake(10.f, 7.f, kScreenWidth -73, 30.f):CGRectMake(10.f, 7.f, kScreenWidth - kTabBarWidth -73, 30.f)];
        self.inputTextField.delegate = self;
        _inputTextField.backgroundColor = UIColorFromRGB(0xffffff);
        _inputTextField.textAlignment = NSTextAlignmentLeft;
        _inputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _inputTextField.borderStyle = UITextBorderStyleNone;
        _inputTextField.layer.cornerRadius = 2.0f;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 5, 0)];
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        _inputTextField.font = [UIFont systemFontOfSize:14.0f];
        self.inputTextField.borderStyle = UITextBorderStyleNone;
        self.inputTextField.returnKeyType = UIReturnKeySend;
        _inputTextField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
//        if (iOS7) {
//            [self.inputTextField setTintColor:UIColorFromRGB(0x6d9acb)];
//        }
        [self.inputBar addSubview:self.inputTextField];
        
        UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputTextField.deFrameRight + 5.f, 7.f, 50.f, 30.f)];
        [postButton setTitle:@"发送" forState:UIControlStateNormal];
        [postButton setBackgroundColor:UIColorFromRGB(0x6eaaf0)];
        postButton.layer.cornerRadius = 2;
        postButton.layer.masksToBounds = YES;
        postButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [postButton addTarget:self action:@selector(postButtonAction) forControlEvents:UIControlEventTouchUpInside];
        postButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin;
        [self.inputBar addSubview:postButton];
    }
    
    self.tableView.tableHeaderView = self.headerView;
    self.headerView.note = self.note;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.dataArrayForComment.count ==0) {
        [self.tableView.pullToRefreshView startAnimating];
        [self refresh];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
         
         self.tableView.frame = CGRectMake(0.f, 0.f, kScreenWidth - kTabBarWidth, kScreenHeight);
         self.headerView.note = self.note;
         self.inputBar.frame = CGRectMake(0., self.view.deFrameBottom - 108., kScreenWidth - kTabBarWidth, kToolBarHeight);
//         self.inputTextField.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
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
    
    [API getNoteDetailWithNoteId:self.note.noteId success:^(GKNote *note, GKEntity *entity, NSArray *commentArray, NSArray *pokerArray) {
        self.dataArrayForComment = [NSMutableArray arrayWithArray:commentArray];
        if ([commentArray count] > 0) {
            self.tableView.tableFooterView = nil;
        } else {
            self.tableView.tableFooterView = self.footerView;
        }
        
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
    } failure:^(NSInteger stateCode) {
        //[SVProgressHUD showImage:nil status:NSLocalizedStringFromTable(@"load failure", kLocalizedFile, nil)];
            [SVProgressHUD dismiss];
        [self.tableView.pullToRefreshView stopAnimating];
    }];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArrayForComment.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
    cell.comment = [self.dataArrayForComment objectAtIndex:indexPath.row];
    cell.tapReplyButtonBlock = ^(GKComment *comment) {
        self.inputTextField.placeholder = [NSString stringWithFormat:@"回复 %@：", comment.creator.nickname];
        self.inputTextField.tag = comment.commentId;
        [self.inputTextField becomeFirstResponder];
    };
    
    return cell;
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [CommentCell height:[self.dataArrayForComment objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKComment *comment = self.dataArrayForComment[indexPath.row];
    if (comment.creator == [Passport sharedInstance].user ||
        self.note.creator == [Passport sharedInstance].user) {
        return YES;
    } else {
        return NO;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKComment *comment = self.dataArrayForComment[indexPath.row];
    self.inputTextField.placeholder = [NSString stringWithFormat:@"回复 %@：", comment.creator.nickname];
    self.inputTextField.tag = comment.commentId;
    [self.inputTextField becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKComment *comment = self.dataArrayForComment[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除评论
        [API deleteCommentByNoteId:comment.noteId commentId:comment.commentId success:^() {
            [self.dataArrayForComment removeObjectAtIndex:indexPath.row];
            self.note.commentCount -=1;
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            if (self.note.commentCount == 0) {
                self.tableView.tableFooterView = self.footerView;
            }
        } failure:nil];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.inputTextField resignFirstResponder];
}

#pragma mark - Keyboard Events

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.inputBar.deFrameBottom = kScreenHeight - kStatusBarHeight - kNavigationBarHeight - height;
    }];
}

#pragma mark - Selector Methdo

- (void)postButtonAction
{
    if(!k_isLogin)
    {
//        LoginView * view = [[LoginView alloc]init];
//        [view show];
        [[OpenCenter sharedOpenCenter] openAuthPageWithSuccess:^{
            
        }];
        return;
    }
    NSString *content = self.inputTextField.text;
    
    if (content.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入评论内容"];
        return;
    }
    if (self.inputTextField.tag == 0) {
        [API postCommentWithNoteId:self.note.noteId content:content success:^(GKComment *comment) {
//            [SVProgressHUD showImage:nil status:@"评论成功"];
            [SVProgressHUD showSuccessWithStatus:@"评论成功"];
            self.note.commentCount += 1;
            [self.dataArrayForComment addObject:comment];
            [self.tableView reloadData];
            self.inputTextField.text = @"";
            [self.inputTextField resignFirstResponder];
            self.tableView.tableFooterView = nil;
            
        } failure:^(NSInteger stateCode) {
//            [SVProgressHUD showImage:nil status:@"评论失败"];
            [SVProgressHUD showErrorWithStatus:@"评论失败"];
        }];
    }else{
        GKComment *comment = [GKComment modelFromDictionary:@{@"entityId":self.note.entityId, @"noteId":@(self.note.noteId), @"commentId":@(self.inputTextField.tag)}];
        
        [API replyCommentWithNoteId:self.note.noteId commentId:comment.commentId commentCreatorId:comment.creator.userId content:self.inputTextField.text success:^(GKComment *comment) {
            self.note.commentCount += 1;
            self.inputTextField.text = nil;
            [self.inputTextField resignFirstResponder];
            [self.dataArrayForComment addObject:comment];
            [self.tableView reloadData];
            [self.tableView scrollsToTop];
//            [SVProgressHUD showImage:nil status:@"回复成功!"];
            [SVProgressHUD showSuccessWithStatus:@"回复成功"];
            
            [MobClick event:@"post reply success"];
//            [AVAnalytics event:@"post reply success"];
        } failure:^(NSInteger stateCode) {
//            [SVProgressHUD showImage:nil status:@"回复失败!"];
            [SVProgressHUD showErrorWithStatus:@"回复失败"];
            
            [MobClick event:@"post reply success"];
//            [AVAnalytics event:@"post reply success"];
        }];
    }

}

#pragma mark - Comment Header View Delegate
- (void)TapAvatarButtonAction:(id)sender
{
    UserViewController * VC = [[UserViewController alloc]init];
    VC.user = self.note.creator;
    [kAppDelegate.activeVC.navigationController pushViewController:VC animated:YES];
    
//    [AVAnalytics event:@"note_forward_user"];
    [MobClick event:@"note_forward_user"];
}

- (void)TapPokeButtonAction:(id)sender
{
    UIButton * pokeBtn = (UIButton *)sender;
    if(!k_isLogin)
    {
//        LoginView * view = [[LoginView alloc]init];
//        [view show];
        [[OpenCenter sharedOpenCenter] openAuthPageWithSuccess:^{
            
        }];
        return;
    }
    [API pokeWithNoteId:self.note.noteId state:!pokeBtn.selected success:^(NSString *entityId, NSUInteger noteId, BOOL poked) {
        if (poked == pokeBtn.selected) {
            
        }
        else if (poked) {
            self.note.pokeCount = self.note.pokeCount+1;
        } else {
            self.note.pokeCount = self.note.pokeCount-1;
        }
        self.note.poked = poked;
        [pokeBtn setTitle:[NSString stringWithFormat:@"%@ %ld",[NSString fontAwesomeIconStringForEnum:FAThumbsOUp],(unsigned long)self.note.pokeCount] forState:UIControlStateNormal];
        pokeBtn.selected = self.note.poked;
        
//        [AVAnalytics event:@"poke note" attributes:@{@"note": @(self.note.noteId), @"status":@"success"} durations:(int)self.note.pokeCount];
        [MobClick event:@"poke note" attributes:@{@"note": @(self.note.noteId), @"status":@"success"} counter:(int)self.note.pokeCount];
    } failure:^(NSInteger stateCode) {
//        [AVAnalytics event:@"poke note" attributes:@{@"note":@(self.note.noteId), @"status":@"failure"}];
        [MobClick event:@"poke note" attributes:@{@"note":@(self.note.noteId), @"status":@"failure"}];
    }];
}

@end
