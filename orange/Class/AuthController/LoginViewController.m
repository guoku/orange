//
//  LoginViewController.m
//  orange
//
//  Created by huiter on 15/12/10.
//  Copyright © 2015年 guoku.com. All rights reserved.
//

#import "LoginViewController.h"
#import "Passport.h"
//#import "AppDelegate.h"
#import "API.h"
#import <libWeChatSDK/WXApi.h>
#import <WeiboSDK/WeiboUser.h>

#import "SignInView.h"
#import "ForgetPasswdController.h"
#import <1PasswordExtension/OnePasswordExtension.h>

@interface LoginViewController ()<UIAlertViewDelegate, SignInViewDelegate>

@property (strong, nonatomic) SignInView    * signView;
@property (strong, nonatomic) UIButton      * dismissBtn;

//@property(nonatomic, strong) id<ALBBLoginService> loginService;
//@property(nonatomic, strong) loginSuccessCallback loginSuccessCallback;
//@property(nonatomic, strong) loginFailedCallback loginFailedCallback;

@end

@implementation LoginViewController

#pragma mark - lazy load view
- (SignInView *)signView
{
    if (!_signView) {
        _signView = [[SignInView alloc] initWithFrame:CGRectMake(0., 0., kScreenWidth, kScreenHeight)];
//        _signView.backgroundColor = UIColorFromRGB(0xffffff);
        _signView.delegate = self;
        
    }
    return _signView;
}

- (UIButton *)dismissBtn
{
    if (!_dismissBtn) {
        _dismissBtn                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.deFrameSize     = CGSizeMake(32., 44.);
        
        [_dismissBtn setImage:[UIImage imageNamed:@"back-1"] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismissBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (void)loadView
{
    self.view = self.signView;
    self.title = NSLocalizedStringFromTable(@"sign in", kLocalizedFile, nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponder:)];
    [self.signView addGestureRecognizer:tap];
//
    
    if (IS_IPAD) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.dismissBtn];
    }
    
#pragma mark - login from sns
//    _loginService = [[ALBBSDK sharedInstance]getService:@protocol(ALBBLoginService)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWeChatCode:) name:@"WechatAuthResp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postWBCode:) name:@"WBAuthResp" object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
//    self.navigationController.navigationBar.hidden = NO;'
    [MobClick beginLogPageView:@"SignInView"];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [MobClick endLogPageView:@"SignInView"];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 
- (void)resignResponder:(id)sender
{
    [self.signView resignResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)finishedBaichuanWithSession:(ALBBSession *)session
{
    [Passport sharedInstance].taobaoId = [session getUser].openId;
    [Passport sharedInstance].screenName = [session getUser].nick;
    [SVProgressHUD show];
    [API loginWithBaichuanUid:[session getUser].openId nick:[session getUser].nick  success:^(GKUser *user, NSString *session) {

        NSString *uidString = [NSString stringWithFormat:@"%ld", [Passport sharedInstance].user.userId];
        [MobClick profileSignInWithPUID:uidString provider:@"taobao"];
        [SVProgressHUD showImage:nil status:[NSString stringWithFormat: @"%@%@",smile,@"登录成功"]];
//        [self dismiss];
        if (IS_IPAD) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.signInSuccessBlock) {
                    self.signInSuccessBlock(YES);
                }
            }];
        } else {
            if (self.signInSuccessBlock) {
                self.signInSuccessBlock(YES);
            }
        }
    } failure:^(NSInteger stateCode, NSString *type, NSString *message) {
        [MobClick event:@"sign in from taobao" label:@"failure"];
//        [kAppDelegate.window makeKeyAndVisible];
//        kAppDelegate.alertWindow.hidden = YES;
        [SVProgressHUD showErrorWithStatus:message];
        
    }];
}


#pragma mark - Notification
- (void)postWeChatCode:(NSNotification *)notification
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    SendAuthResp *resp = [notification valueForKey:@"object"];
    
    NSDictionary * json = [API getWeChatAuthWithAppKey:kGK_WeixinShareKey Secret:KGK_WeixinSecret Code:resp.code];
    
    NSDictionary * userInfo = [API getWeChatUserInfoWithAccessToken:[json valueForKey:@"access_token"] OpenID:[json valueForKey:@"openid"]];
    
    [API loginWithWeChatWithUnionid:[userInfo valueForKey:@"unionid"] Nickname:[userInfo valueForKey:@"nickname"] HeaderImgURL:[userInfo valueForKey:@"headimgurl"] success:^(GKUser *user, NSString *session) {
//        [MobClick event:@"sign in from wechat" label:@"success"];
        NSString *uidString = [NSString stringWithFormat:@"%ld", [Passport sharedInstance].user.userId];
        [MobClick profileSignInWithPUID:uidString provider:@"wechat"];
        [SVProgressHUD showImage:nil status:[NSString stringWithFormat: @"%@%@", smile, @"登录成功"]];
//        [self dismiss];
        if (IS_IPAD) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.signInSuccessBlock) {
                    self.signInSuccessBlock(YES);
                }
            }];
        } else {
            if (self.signInSuccessBlock) {
                self.signInSuccessBlock(YES);
            }
        }
    } failure:^(NSInteger stateCode, NSString *type, NSString *message) {
        [MobClick event:@"sign in from wechat" label:@"failure"];
        [SVProgressHUD showErrorWithStatus:message];
    }];
    
}

- (void)postWBCode:(NSNotification *)notification
{
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTable(@"loading", kLocalizedFile, nil)];
    
    NSDictionary * WBUserInfo = [notification valueForKey:@"object"];
    NSString * access_token = [[NSUserDefaults standardUserDefaults] valueForKey:@"wbtoken"];
    DDLogError(@"user info %@", WBUserInfo);
    [WBHttpRequest requestForUserProfile:[WBUserInfo valueForKey:@"uid"] withAccessToken:access_token andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {

        if (!error) {
            WeiboUser * wb_user = (WeiboUser *)result;
            [API loginWithSinaUserId:wb_user.userID sinaToken:access_token ScreenName:wb_user.screenName success:^(GKUser *user, NSString *session) {
//                [MobClick event:@"sign in from weibo" label:@"success"];
                NSString *uidString = [NSString stringWithFormat:@"%ld", [Passport sharedInstance].user.userId];
                [MobClick profileSignInWithPUID:uidString provider:@"weibo"];
                if (IS_IPAD) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        if (self.signInSuccessBlock) {
                            self.signInSuccessBlock(YES);
                        }
                    }];
                } else {
                    if (self.signInSuccessBlock) {
                        self.signInSuccessBlock(YES);
                    }
                }
                
            } failure:^(NSInteger stateCode, NSString *type, NSString *message) {
                [SVProgressHUD showErrorWithStatus:message];
                [MobClick event:@"sign in from weibo" label:@"failure"];
            }];
        } else {
            DDLogError(@"weibo error %@", [[error userInfo] objectForKey:@"NSLocalizedRecoverySuggestion"]);
            [MobClick event:@"sign in from weibo" label:@"failure"];
            [SVProgressHUD showErrorWithStatus:[[error userInfo] valueForKey:@"NSLocalizedRecoverySuggestion"]];
        }
    }];
}

#pragma mark - <SignInViewDelegate>
- (void)tapSignBtnWithEmail:(NSString *)email Password:(NSString *)password
{
//    NSString *email = self.emailTextField.text;
//    NSString *password = self.passwordTextField.text;

    
    if (!email || email.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入邮箱"];
        return;
    }
    
    if (![email isValidEmail]) {
        [SVProgressHUD showImage:nil status:@"请输入正确格式的邮箱"];
        return;
    }
    
    if (!password || password.length == 0) {
        [SVProgressHUD showImage:nil status:@"请输入密码"];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedStringFromTable(@"login...", kLocalizedFile, nil)];
    [API loginWithEmail:email password:password success:^(GKUser *user, NSString *session) {
//        if (self.signInSuccessBlock) {
//            self.signInSuccessBlock(YES);
//        }
//        [MobClick event:@"sign in" label:@"success"];
        NSString *uidString = [NSString stringWithFormat:@"%ld", [Passport sharedInstance].user.userId];
        [MobClick profileSignInWithPUID:uidString];
        
        [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
        if (IS_IPAD) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.signInSuccessBlock) {
                    self.signInSuccessBlock(YES);
                }
            }];
        } else {
            if (self.signInSuccessBlock) {
                self.signInSuccessBlock(YES);
            }
        }
    } failure:^(NSInteger stateCode, NSString *type, NSString *message) {
        [MobClick event:@"sign in" label:@"failure"];
        switch (stateCode) {
            case 500:
            {
                [SVProgressHUD showImage:nil status:@"服务器出错!"];
                break;
            }
            case 400:
            default:
                [SVProgressHUD showErrorWithStatus:message];
                break;
        }
        
    }];
}

#pragma mark - button action

- (void)dismissBtnAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapForgetBtn:(id)sender
{
    ForgetPasswdController * fpController = [[ForgetPasswdController alloc] init];
    
    [self.navigationController pushViewController:fpController animated:YES];
}

- (void)tapWeiBoBtn:(id)sender
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kGK_WeiboRedirectURL;
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"LoginViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

- (void)tapTaobaoBtn:(id)sender
{
////    DDLogInfo(@"taobao taobao");
//    if (![[TaeSession sharedInstance] isLogin]){
//        __weak __typeof(&*self)weakSelf = self;
//        _loginSuccessCallback = ^(TaeSession * session) {
//            [weakSelf finishedBaichuanWithSession:session];
//        };
//        
//        _loginFailedCallback = ^(NSError * error) {
//            //            [self closeTaobaoView];
////            [kAppDelegate.window makeKeyAndVisible];
////            kAppDelegate.alertWindow.hidden = YES;
//        };
//        
//        [_loginService showLogin:self successCallback:_loginSuccessCallback failedCallback:_loginFailedCallback notUseTaobaoAppLogin:YES];
//    } else {
//        TaeSession *session = [TaeSession sharedInstance];
//        [self finishedBaichuanWithSession:session];
//    }
    
    if ([ALBBSession sharedInstance].isLogin) {
//        ALBBSession *session    = [ALBBSession sharedInstance];
        [self finishedBaichuanWithSession:[ALBBSession sharedInstance]];
    } else {
        [[ALBBSDK sharedInstance] auth:self successCallback:^(ALBBSession *session) {
            [self finishedBaichuanWithSession:session];
        } failureCallback:^(ALBBSession *session, NSError *error) {
        
        }];
    }
}

- (void)tapWeChatBtn:(id)sender
{
    if([WXApi isWXAppInstalled]) {
        SendAuthReq * req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"guoku_signin_wechat";
        [WXApi sendReq:req];
    } else {
        
    }
}

- (void)handleTapOnePassword:(id)sender
{
    [[OnePasswordExtension sharedExtension] findLoginForURLString:@"http://guoku.com" forViewController:self sender:sender completion:^(NSDictionary * _Nullable loginDictionary, NSError * _Nullable error) {
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }
        self.signView.emailTextField.text       = loginDictionary[AppExtensionUsernameKey];
        self.signView.passwordTextField.text    = loginDictionary[AppExtensionPasswordKey];
        
        [self tapSignBtnWithEmail:loginDictionary[AppExtensionUsernameKey] Password:loginDictionary[AppExtensionPasswordKey]];
    }];
}

@end
