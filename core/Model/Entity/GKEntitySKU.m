//
//  GKEntitySKU.m
//  orange
//
//  Created by 谢家欣 on 16/8/22.
//  Copyright © 2016年 guoku.com. All rights reserved.
//

#import "GKEntitySKU.h"


@implementation GKEntitySKU

+ (NSDictionary *)dictionaryForServerAndClientKeys
{
    NSDictionary *keyDic = @{
                             @"id"              : @"skuId",
                             @"entity_id"       : @"entityId",
                             @"origin_price"    : @"originPrice",
                             @"discount"        : @"discount",
                             @"promo_price"     : @"promoPrice",
                             @"stock"           : @"stock",
                             @"attrs"           : @"attrs",
                             };
    
    return keyDic;
}

+ (NSArray *)keyNames
{
    return @[@"skuId"];
}

- (void)setAttrs:(id)attrs
{
//    NSLog(@"attrs %@", attrs.items());
    if ([attrs isKindOfClass:[NSDictionary class]]) {
        _attrs = attrs;
    } else {
        NSData *data = [attrs dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _attrs = json;
        
    }
}

@end