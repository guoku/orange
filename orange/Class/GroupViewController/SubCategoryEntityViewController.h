//
//  SubCategoryEntityViewController.h
//  orange
//
//  Created by 谢家欣 on 15/9/15.
//  Copyright © 2015年 guoku.com. All rights reserved.
//

#import "BaseViewController.h"

@interface SubCategoryEntityViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

//@property (assign, nonatomic) NSInteger sid;
@property (assign, nonatomic) GKEntityCategory * subcategory;

//- (instancetype)initWithSID:(NSInteger)sid;
- (instancetype)initWithSubCategory:(GKEntityCategory *)subcategory;

@end