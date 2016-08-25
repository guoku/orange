//
//  ArticleCell.m
//  orange
//
//  Created by 谢家欣 on 15/9/5.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "ArticleCell.h"

@interface ArticleCell () <RTLabelDelegate>

@property (strong, nonatomic) UIImageView * coverImageView;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UILabel * detailLabel;
//@property (strong, nonatomic) RTLabel * tagsLabel;
@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) UIView * H;

@end

@implementation ArticleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.backgroundColor = UIColorFromRGB(0xffffff);
        self.backgroundColor = [UIColor colorFromHexString:@"#ffffff"];
        
        _H = [[UIView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 0.5)];
        self.H.backgroundColor = UIColorFromRGB(0xe6e6e6);
        [self.contentView addSubview:self.H];
    }
    return self;
}

- (UIImageView *)coverImageView
{
    if (!_coverImageView){
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_coverImageView];
    }
    return _coverImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel                 = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font            = [UIFont boldSystemFontOfSize:17.];
        _titleLabel.textColor       = [UIColor colorFromHexString:@"#414243"];
        _titleLabel.textAlignment   = NSTextAlignmentLeft;
        _titleLabel.numberOfLines   = 2;
        
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        _detailLabel                = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.font           = [UIFont systemFontOfSize:14.];
        _detailLabel.numberOfLines  = 2;
        _detailLabel.textColor      = [UIColor colorFromHexString:@"#9d9e9f"];
        
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

//- (RTLabel *)tagsLabel
//{
//    if (!_tagsLabel) {
//        _tagsLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
//        _tagsLabel.paragraphReplacement = @"";
//        _tagsLabel.lineSpacing = 7.;
//        _tagsLabel.delegate = self;
//        [self.contentView addSubview:_tagsLabel];
//    }
//    return _tagsLabel;
//}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel                  = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font             = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
        _timeLabel.textColor        = [UIColor colorFromHexString:@"#9d9e9f"];
        _timeLabel.textAlignment    = NSTextAlignmentRight;
        
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (void)setArticle:(GKArticle *)article
{
    _article = article;
    
    self.titleLabel.text = _article.title;
    
    self.detailLabel.text = _article.digest;
//    self.detailLabel.text = [_article.content trimed];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.detailLabel.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7.];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.detailLabel.text length])];
    self.detailLabel.attributedText = attributedString;
    self.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    /**
     *  设置图片
     */
    [self.coverImageView sd_setImageWithURL:_article.coverURL placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xebebeb) andSize:CGSizeMake(kScreenWidth -32, (kScreenWidth - 32) / 1.8)]];
    
    /**
     *  设置图文标签
     */
//    NSMutableString * tagListString = [NSMutableString string];
//    for (NSString * row in self.article.tags) {
//        NSString * tagString = [NSString stringWithFormat:@"<a href=%@><font color='^9d9e9f' size=12>#%@</font></a> ", [row encodedUrl], row];
//        [tagListString appendString:tagString];
//    }
//    self.tagsLabel.text = tagListString;
    
    /**
     *  设置发布时间
     */
    NSDate * date =  [NSDate dateWithTimeIntervalSince1970:_article.pub_time];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date stringWithDefaultFormat]];
    
    [self setNeedsLayout];
//    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (IS_IPAD) {
#pragma mark - layout ipad
        self.coverImageView.frame = CGRectMake(0., 0., self.contentView.deFrameWidth - 32, (self.contentView.deFrameWidth - 32) / 1.8);
        self.coverImageView.deFrameTop = 16.;
        self.coverImageView.deFrameLeft = 16;
        
        CGFloat height = [self.article.title heightWithLineWidth:self.contentView.deFrameWidth - 32 Font:[UIFont systemFontOfSize:17.] LineHeight:7];
        self.titleLabel.frame = CGRectMake(0., 0., self.contentView.deFrameWidth - 32., height);
        self.titleLabel.deFrameLeft = 16.;
        self.titleLabel.deFrameTop = self.coverImageView.deFrameBottom + 10.;
        
        self.detailLabel.frame = CGRectMake(0., 0., self.contentView.deFrameWidth - 32, 70);
        self.detailLabel.center = self.titleLabel.center;
        self.detailLabel.deFrameTop = self.titleLabel.deFrameBottom + 5;
        
        self.timeLabel.frame = CGRectMake(0., 0., 100., 20.);
        self.timeLabel.deFrameBottom = self.contentView.deFrameHeight - 12.;
        self.timeLabel.deFrameRight = self.contentView.deFrameRight - 16.;
    
    } else {
#pragma mark - layout iphone
        self.coverImageView.frame = CGRectMake(0., 0., kScreenWidth - 32, (kScreenWidth - 32) / 1.8);
        self.coverImageView.deFrameTop = 16.;
        self.coverImageView.deFrameLeft = 16;
    
        CGFloat height = [self.article.title heightWithLineWidth:kScreenWidth - 32 Font:[UIFont systemFontOfSize:17.] LineHeight:7];
    
        self.titleLabel.frame = CGRectMake(0., 0., kScreenWidth - 32., height);
        self.titleLabel.deFrameLeft = 16.;
        self.titleLabel.deFrameTop = self.coverImageView.deFrameBottom + 16;
    
        self.detailLabel.frame = CGRectMake(0., 0., kScreenWidth -32, 45);
        self.detailLabel.center = self.titleLabel.center;
        self.detailLabel.deFrameTop = self.titleLabel.deFrameBottom + 10;
    
//    self.tagsLabel.frame = CGRectMake(0., 0., 200., 20.);
//    self.tagsLabel.deFrameBottom = self.contentView.deFrameHeight - 12.;
//    self.tagsLabel.deFrameLeft = self.contentView.deFrameLeft + 16.;
    
        self.timeLabel.frame = CGRectMake(0., 0., 100., 20.);
        self.timeLabel.deFrameBottom = self.contentView.deFrameHeight - 12.;
        self.timeLabel.deFrameRight = self.contentView.deFrameRight - 10.;
    
        self.H.deFrameBottom = self.deFrameHeight;
    }
    
} 

#pragma mark - <RTLabelDelegate>
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [[OpenCenter sharedOpenCenter] openArticleTagWithName:url.absoluteString];
}


#pragma mark - class method

+ (CGSize)CellSizeWithArticle:(GKArticle *)article
{
    CGFloat height = [article.title heightWithLineWidth:kScreenWidth - 32 Font:[UIFont systemFontOfSize:17.] LineHeight:8];
//    NSLog(@"%f", height);
    
    CGSize size = CGSizeMake(kScreenWidth,height + 125 + 174* kScreenWidth/(375-32));
    
    /*
    if (height > 25) {
        size = CGSizeMake(kScreenWidth, 165 + 174* kScreenWidth/(375-32));
    }*/
    return size;
}

@end
