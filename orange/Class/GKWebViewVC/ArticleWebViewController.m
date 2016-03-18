//
//  ArticleWebViewController.m
//  orange
//
//  Created by D_Collin on 16/3/15.
//  Copyright © 2016年 guoku.com. All rights reserved.
//

#import "ArticleWebViewController.h"
#import "WXApi.h"

#import <WebKit/WebKit.h>
#import "WebViewProgressView.h"
#import "SDWebImageDownloader.h"
#import "EntityViewController.h"

#import "ShareView.h"
#import "LoginView.h"

@interface ArticleWebViewController ()<WKNavigationDelegate , WKUIDelegate>

//@property (nonatomic , strong)NSURL * url;
//@property (nonatomic , strong)WKWebView * webView;
@property (nonatomic , strong)WebViewProgressView * progressView;
@property (nonatomic , strong)UIImage * image;
@property (nonatomic , strong)UIButton * digBtn;
@property (nonatomic , strong)UIButton * moreBtn;


@end

@implementation ArticleWebViewController

- (instancetype)initWithArticle:(GKArticle *)article
{
    if (self) {
        self.article = article;
        self.url = self.article.articleURL;
    }
    return self;
}

- (WKWebView *)webView
{
    if (!_webView) {
        
        // Javascript that disables pinch-to-zoom by inserting the HTML viewport meta tag into <head>
        NSString *source = @"var style = document.createElement('style'); \
        style.type = 'text/css'; \
        style.innerText = '*:not(input):not(textarea) { -webkit-user-select: none; -webkit-touch-callout: none; }'; \
        var head = document.getElementsByTagName('head')[0];\
        head.appendChild(style);";
        WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        // Create the user content controller and add the script to it
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addUserScript:script];
        
        // Create the configuration with the user content controller
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = userContentController;
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0., 0., kScreenWidth, kScreenHeight) configuration:configuration];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [_webView sizeToFit];
    }
    return _digBtn;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray * BtnArray = [NSMutableArray array];
    
    //更多按钮
    _moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 44)];
    [_moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    _moreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_moreBtn addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * moreBarItem = [[UIBarButtonItem alloc]initWithCustomView:_moreBtn];
    
    [BtnArray addObject:moreBarItem];
    
    //点赞按钮
     _digBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     _digBtn.frame = CGRectMake(0., 0., 32, 44);
     _digBtn.tintColor = UIColorFromRGB(0xffffff);
    [_digBtn setImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
//    [_digBtn setImage:[UIImage imageNamed:@"thumbed"] forState:UIControlStateHighlighted];
    [_digBtn setImage:[UIImage imageNamed:@"thumbed"] forState:UIControlStateSelected];
    [_digBtn addTarget:self action:@selector(digBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_digBtn setImageEdgeInsets:UIEdgeInsetsMake(0., 0., 0., 0.)];
    _digBtn.backgroundColor = [UIColor clearColor];
    if (self.article.IsDig) {
        _digBtn.selected = YES;
    }
    UIBarButtonItem * likeBarItem = [[UIBarButtonItem alloc]initWithCustomView:_digBtn];
    [BtnArray addObject:likeBarItem];
    [self.navigationItem setRightBarButtonItems:BtnArray animated:YES];
    
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0., 0., 32., 44.);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0., 0., 0., 20.);
    UIBarButtonItem * backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backBarItem;
    
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[WebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar addSubview:self.progressView];
    
    //    [AVAnalytics beginLogPageView:@"webView"];
    [MobClick beginLogPageView:@"articleWebView"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.progressView removeFromSuperview];
    
    [MobClick endLogPageView:@"articleWebView"];
}


#pragma mark - button action
- (void)moreButtonAction:(id)sender
{
    UIImage * image = [UIImage imageNamed:@"wxshare"];
    if (self.image) {
        image = [UIImage imageWithData:[self.image imageDataLessThan_10K]];
    }
    
    
    ShareView * view = [[ShareView alloc]initWithTitle:self.title SubTitle:@"" Image:image URL:[self.webView.URL absoluteString]];
    view.type = @"url";
    view.tapRefreshButtonBlock = ^(){
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    };
    [view show];
}

#pragma mark - button action
- (void)digBtnAction:(UIButton *)btn
{
//    NSLog(@"OKOKOKOKO");
    if(!k_isLogin)
    {
        LoginView * view = [[LoginView alloc]init];
        [view show];
        return;
    }
    else
    {
        [API digArticleWithArticleId:self.article.articleId isDig:!self.digBtn.selected success:^(BOOL IsDig) {
            
            if (IsDig == self.digBtn.selected)
            {
                [SVProgressHUD showImage:nil status:@"点赞成功"];
            }
                    self.digBtn.selected = IsDig;
                    self.article.IsDig = IsDig;
                    
                    if (IsDig)
                    {
                        self.article.dig_count += 1;
                        NSLog(@"%ld",self.article.dig_count);
                    }
                    else
                    {
                        self.article.dig_count -= 1;
                        NSLog(@"%ld",self.article.dig_count);
                    }
                    if (btn) {
                        btn.selected = self.article.IsDig;
                    }
                    
            } failure:^(NSInteger stateCode) {
                [SVProgressHUD showImage:nil status:@"点赞失败"];
            }];
    }
}

#pragma mark - button action
- (void)backAction:(id)sender
{
    if([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        //        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//#pragma mark - webview kvo
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
//        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
//    }
//    else {
//        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}
@end
