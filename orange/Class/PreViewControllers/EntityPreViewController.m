//
//  EntityPreViewController.m
//  orange
//
//  Created by 谢家欣 on 15/11/24.
//  Copyright © 2015年 guoku.com. All rights reserved.
//

#import "EntityPreViewController.h"
#import "EntityPreView.h"
#import "LoginView.h"

#import "WebViewController.h"
@interface EntityPreViewController ()

@property (strong, nonatomic) GKEntity * entity;
@property (strong, nonatomic) EntityPreView * preView;

@property(nonatomic, strong) id<ALBBItemService> itemService;


@end

@implementation EntityPreViewController
{
    tradeProcessSuccessCallback _tradeProcessSuccessCallback;
    tradeProcessFailedCallback _tradeProcessFailedCallback;
}
- (instancetype)initWithEntity:(GKEntity *)entity
{
    self = [super init];
    if (self) {
        self.entity = entity;
    }
    return self;
}

- (EntityPreView *)preView
{
    if (!_preView) {
        _preView = [[EntityPreView alloc] initWithFrame:CGRectMake(0., 0., kScreenWidth, kScreenHeight)];
        _preView.entity = self.entity;
        _preView.backgroundColor = UIColorFromRGB(0xffffff);
    }
    return _preView;
}

- (void)loadView
{
    self.view = self.preView;
}

#pragma mark -
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action = [UIPreviewAction actionWithTitle:NSLocalizedStringFromTable(@"like", kLocalizedFile, nil) style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        if(!k_isLogin)
        {
            LoginView * view = [[LoginView alloc]init];
            [view show];
            return;
        }
        
        [AVAnalytics event:@"like_click" attributes:@{@"entity":self.entity.title} durations:(int)self.entity.likeCount];
        [MobClick event:@"like_click" attributes:@{@"entity":self.entity.title} counter:(int)self.entity.likeCount];
        
        [API likeEntityWithEntityId:self.entity.entityId isLike:YES success:^(BOOL liked) {
            self.entity.liked = liked;
        } failure:^(NSInteger stateCode) {
            [SVProgressHUD showImage:nil status:@"喜爱失败"];
        }];
    }];
#pragma mark --------------- 点击跳转至购买页 ---------------------
    UIPreviewAction * action2 = [UIPreviewAction actionWithTitle:NSLocalizedStringFromTable(@"buy", kLocalizedFile, nil) style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //code signing
    
        if (self.entity.purchaseArray.count > 0) {
            GKPurchase * purchase = self.entity.purchaseArray[0];
            
            if ([purchase.source isEqualToString:@"taobao.com"] || [purchase.source isEqualToString:@"tmall.com"]) {
                NSNumber * _itemId = [[[NSNumberFormatter alloc] init] numberFromString:purchase.origin_id];
                TaeTaokeParams * taoKeParams = [[TaeTaokeParams alloc]init];
                taoKeParams.pid = kGK_TaobaoKe_PID;
                [_itemService showTaoKeItemDetailByItemId:self
                                               isNeedPush:YES
                                        webViewUISettings:nil
                                                   itemId:_itemId
                                                 itemType:1
                                                   params:nil
                                              taoKeParams:taoKeParams
                              tradeProcessSuccessCallback:_tradeProcessSuccessCallback
                               tradeProcessFailedCallback:_tradeProcessFailedCallback];
                
                [self showWebViewWithTaobaoUrl:[purchase.buyLink absoluteString] ];
                
                [AVAnalytics event:@"buy action" attributes:@{@"entity":self.entity.title} durations:(int)self.entity.lowestPrice];
                [MobClick event:@"purchase" attributes:@{@"entity":self.entity.title} counter:(int)self.entity.lowestPrice];
                
            }
            else{
                
            }
        }
        
    }];
    
    return @[action,action2];
}

- (void)showWebViewWithTaobaoUrl:(NSString *)taobao_url
{
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    NSString * TTID = [NSString stringWithFormat:@"%@_%@",kTTID_IPHONE,[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    NSString *sid = @"";
    taobao_url = [taobao_url stringByReplacingOccurrencesOfString:@"&type=mobile" withString:@""];
    NSString *url = [NSString stringWithFormat:@"%@&sche=com.guoku.iphone&ttid=%@&sid=%@&type=mobile&outer_code=IPE",taobao_url, TTID,sid];
    GKUser *user = [Passport sharedInstance].user;
    if(user)
    {
        url = [NSString stringWithFormat:@"%@%lu",url,user.userId];
    }

    WebViewController *webVC =[[WebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    
        webVC.title = @"宝贝详情";
        webVC.hidesBottomBarWhenPushed = YES;
    if(self.backblock){
        self.backblock(webVC);
    }

}


@end
