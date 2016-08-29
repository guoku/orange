//
//  GKArticle.m
//  orange
//
//  Created by 谢家欣 on 15/9/5.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "GKArticle.h"
#import "NSString+Helper.h"

@interface GKArticle ()

@property (strong, nonatomic) NSString * cover;
@property (strong, nonatomic) NSString * url_string;

@end

@implementation GKArticle

//static NSString * imageHost = @"http://imgcdn.guoku.com/";

+ (NSDictionary *)dictionaryForServerAndClientKeys
{
    NSDictionary * keyDic = @{
                            @"article_id"       :   @"articleId",
                            @"title"            :   @"title",
                            @"content"          :   @"content",
//                            @"url"          :   @"url",
                            @"tags"             :   @"tags",
                            @"read_count"       :   @"read_count",
                            @"cover"            :   @"cover",
                            @"url"              :   @"url_string",
                            @"creator"          :   @"creator",
                            @"pub_time"         :   @"pub_time",
                            @"dig_count"        :   @"dig_count",
                            @"is_dig"           :   @"IsDig",
                            @"digest"           :   @"digest",
                            @"comment_count"    :   @"commentCount",
                    };
    
    return keyDic;
}

+ (NSArray *)keyNames
{
    return @[@"articleId"];
}

- (void)setCreator:(id)creator
{
    if ([creator isKindOfClass:[GKUser class]]) {
        _creator    = creator;
    } else {
        _creator = [GKUser modelFromDictionary:creator];
    }
}

- (NSURL *)coverURL
{
    NSString * url_stirng = [NSString stringWithFormat:@"%@%@", KImageHost, self.cover];
    ;
    return [NSURL URLWithString:url_stirng];
//    return [NSURL URLWithString:[url_stirng imageURLWithSize:240.]];
}

- (NSURL *)coverURL_300
{
    NSString * url_stirng = [NSString stringWithFormat:@"%@%@", KImageHost, self.cover];
    ;
    return [NSURL URLWithString:[url_stirng imageURLWithSize:300]];
}

- (NSURL *)articleURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", KWapURL, self.url_string]];
}

@end
