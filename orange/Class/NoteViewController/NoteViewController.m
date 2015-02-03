//
//  NoteViewController.m
//  orange
//
//  Created by huiter on 15/2/1.
//  Copyright (c) 2015年 sensoro. All rights reserved.
//

#import "NoteViewController.h"
#import "GKAPI.h"
#import "CommentCell.h"

@interface NoteViewController ()<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property(strong,nonatomic) NSMutableArray * dataArrayForComment;
@property (nonatomic, strong) UIView *inputBar;
@property (nonatomic, strong) UITextField *inputTextField;

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    self.title = @"评论";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenWidth, kScreenHeight-kNavigationBarHeight - kStatusBarHeight-kToolBarHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = UIColorFromRGB(0xffffff);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf refresh];
    }];
    
    if (!self.inputBar) {
        _inputBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.tableView.deFrameBottom, kScreenWidth, kToolBarHeight)];
        self.inputBar.backgroundColor = UIColorFromRGB(0xf1f1f1);
        [self.view addSubview:self.inputBar];
        
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, 7.f, kScreenWidth -73, 30.f)];
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
        if (iOS7) {
            [self.inputTextField setTintColor:UIColorFromRGB(0x6d9acb)];
        }
        [self.inputBar addSubview:self.inputTextField];
        
        UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(self.inputTextField.deFrameRight + 5.f, 7.f, 50.f, 30.f)];
        [postButton setTitle:@"发送" forState:UIControlStateNormal];
        [postButton setBackgroundColor:UIColorFromRGB(0x427ec0)];
        postButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [postButton addTarget:self action:@selector(postButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.inputBar addSubview:postButton];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.dataArrayForComment.count ==0) {
        [self.tableView.pullToRefreshView startAnimating];
        [self refresh];
    }
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
    
    [GKAPI getNoteDetailWithNoteId:self.note.noteId success:^(GKNote *note, GKEntity *entity, NSArray *commentArray, NSArray *pokerArray) {
        self.dataArrayForComment = [NSMutableArray arrayWithArray:commentArray];
        [self.tableView reloadData];
        [self.tableView.pullToRefreshView stopAnimating];
    } failure:^(NSInteger stateCode) {
        [SVProgressHUD showImage:nil status:@"失败"];
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
    
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.comment = [self.dataArrayForComment objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GKComment *comment = self.dataArrayForComment[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除评论
        [GKAPI deleteCommentByNoteId:comment.noteId commentId:comment.commentId success:^() {
            [self.dataArrayForComment removeObjectAtIndex:indexPath.row];
            self.note.commentCount -=1;
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
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

    NSString *content = self.inputTextField.text;
    
    if (content.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入评论内容"];
        return;
    }
    
        [GKAPI postCommentWithNoteId:self.note.noteId content:content success:^(GKComment *comment) {
            [SVProgressHUD showImage:nil status:@"评论成功"];
            self.note.commentCount += 1;
            [self.dataArrayForComment addObject:comment];
            [self.tableView reloadData];
            self.inputTextField.text = @"";
            [self.inputTextField resignFirstResponder];
 
            
        } failure:^(NSInteger stateCode) {
            [SVProgressHUD showImage:nil status:@"评论失败"];
        }];

}


@end