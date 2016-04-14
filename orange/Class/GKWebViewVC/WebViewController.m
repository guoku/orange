//
//  WebViewController.m
//  orange
//
//  Created by 谢家欣 on 15/5/17.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "WebViewController.h"
#import "WXApi.h"


#import "WebViewProgressView.h"
#import "SDWebImageDownloader.h"
#import "EntityViewController.h"

#import "ShareView.h"
#import "LoginView.h"

@interface WebViewController () 

@property (strong, nonatomic) WebViewProgressView * progressView;
@property (strong, nonatomic) UIImage * image;
@property (nonatomic , assign)NSString * shareTitle;

@end

@implementation WebViewController

- (instancetype)initWithURL:(NSURL *)url
{
    if (self) {
        self.url = url;
//        self.progressProxy = [[WebViewProgress alloc] init];
//        self.progressProxy.webViewProxyDelegate = self;
//        self.progressProxy.progressDelegate = self;
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
        
        // Javascript that disables pinch-to-zoom by inserting the HTML viewport meta tag into <head>
//        NSString *source = @"var meta = document.createElement('meta'); \
//        meta.name = 'viewport'; \
//        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'; \
//        var head = document.getElementsByTagName('head')[0];\
//        head.appendChild(meta);";
//        WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        // Create the user content controller and add the script to it
        WKUserContentController *userContentController = [WKUserContentController new];
        [userContentController addUserScript:script];
        
        // Create the configuration with the user content controller
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = userContentController;
        
//        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0., 0., kScreenWidth, kScreenHeight) configuration:configuration];
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        [_webView sizeToFit];
    }
    return _webView;
}
//
//- (UIActivityIndicatorView *)activityIndicator
//{
//    if (!_activityIndicator) {
//        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        _activityIndicator.color = [UIColor grayColor];
//        _activityIndicator.center = CGPointMake(kScreenWidth / 2., kScreenHeight / 2. - 100.);
//        
//    }
//    return _activityIndicator;
//}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)loadView
{
//    [self.view addSubview:self.webView];
    self.view = self.webView;
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    //    [self.view addSubview:self.activityIndicator];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    NSMutableArray * BtnArray = [NSMutableArray array];
    
    //更多按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 32, 44)];
    [button setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * moreBarItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = moreBarItem;
    [BtnArray addObject:moreBarItem];
    
    
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
    [self.navigationController.navigationBar addSubview:self.progressView];

//    [AVAnalytics beginLogPageView:@"webView"];
    [MobClick beginLogPageView:@"webView"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
    
    [MobClick endLogPageView:@"webView"];
}

#pragma mark - <WKNavigationDelegate>
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
   
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    /**
     *  disable wkwebview zoom  
     */
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView evaluateJavaScript:javascript completionHandler:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
//    NSLog(@"%@", navigationAction.request.URL.absoluteString);
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"guoku"]) {
        NSURL *url = navigationAction.request.URL;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            [app openURL:url];
        }
    }
    //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
    else if (!navigationAction.targetFrame) {
        [self.webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    NSString * imageURL = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('img')[1].src"];
//    UIImageView * a = [[UIImageView alloc]init];
//    [a sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        self.image = image;
//    }];
    
    [webView evaluateJavaScript:@"document.getElementById('share_img').getElementsByTagName('img')[0].src" completionHandler:^(NSString * imageURL, NSError * error) {
        
        if (imageURL) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (finished) {
                    self.image = image;
                }
            }];
        }
        else{
            
            [webView evaluateJavaScript:@"document.getElementsByTagName('img')[1].src" completionHandler:^(NSString * imageURL, NSError * error) {
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (finished) {
                        self.image = image;
                    }
                }];
                
            }];
        }
        
    }];
    

    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *result, NSError *error) {
//        self.title = result;
        self.title = @"图文";
        self.shareTitle = result;
//        NSLog(@"%@",self.shareTitle);
    }];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
}

#pragma mark - button action
- (void)moreButtonAction:(id)sender
{
    UIImage * image = [UIImage imageNamed:@"wxshare"];
    if (self.image) {
        image = [UIImage imageWithData:[self.image imageDataLessThan_10K]];
    }
    
    
    ShareView * view = [[ShareView alloc]initWithTitle:self.shareTitle SubTitle:@"" Image:image URL:[self.webView.URL absoluteString]];
    view.type = @"url";
    view.tapRefreshButtonBlock = ^(){
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    };
    [view show];
    /*
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", kLocalizedFile, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert action sheet's cancel action occured.");
    }];
    
    UIAlertAction * shareWeiboAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"share to weibo", kLocalizedFile, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self weiboShare];
    }];
    
    UIAlertAction * shareWechatAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"share to wechat", kLocalizedFile, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self wxShare:0];
    }];
    
    UIAlertAction * shareMomentAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"share to moment", kLocalizedFile, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self wxShare:1];
    }];
    
    UIAlertAction * openInSafariAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"open in safari", kLocalizedFile, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication]openURL:self.webView.URL];
    }];
    
    [alertController addAction:cancelAction];
    
    [alertController addAction:shareWeiboAction];
    [alertController addAction:shareWechatAction];
    [alertController addAction:shareMomentAction];
    [alertController addAction:openInSafariAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
     */
}

#pragma mark - button action
- (void)likeBtnAction
{
    if(!k_isLogin)
    {
        LoginView * view = [[LoginView alloc]init];
        [view show];
        return;
    }
    else
    {
//        [API digArticleWithArticleId:<#(NSInteger)#> isDig:<#(BOOL)#> success:^(NSArray *dataArray) {
//            <#code#>
//        } failure:^(NSInteger stateCode) {
//            <#code#>
//        }];
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

#pragma mark - webview kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
