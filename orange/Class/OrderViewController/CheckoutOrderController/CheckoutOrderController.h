//
//  CheckoutOrderController.h
//  orange
//
//  Created by 谢家欣 on 16/9/5.
//  Copyright © 2016年 guoku.com. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CheckoutOrderController : BaseViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


- (instancetype)initWithOrder:(GKOrder *)order;

@end