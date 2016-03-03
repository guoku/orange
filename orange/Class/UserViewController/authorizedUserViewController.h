//
//  authorizedUserViewController.h
//  orange
//
//  Created by D_Collin on 16/2/26.
//  Copyright © 2016年 guoku.com. All rights reserved.
//

#import "BaseViewController.h"

@interface authorizedUserViewController : BaseViewController<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic , strong)GKUser * user;

- (instancetype)initWithUser:(GKUser *)user;

@end