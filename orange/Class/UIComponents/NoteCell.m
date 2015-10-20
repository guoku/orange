//
//  NoteCell.m
//  orange
//
//  Created by 谢家欣 on 15/10/19.
//  Copyright © 2015年 guoku.com. All rights reserved.
//

#import "NoteCell.h"

@interface NoteCell ()

@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UILabel * noteLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation NoteCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xffffff);
    }
    return self;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)noteLabel
{
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noteLabel.font = [UIFont systemFontOfSize:14.];
        _noteLabel.textColor = UIColorFromRGB(0x414243);
        _noteLabel.numberOfLines = 3;
        _noteLabel.textAlignment = NSTextAlignmentLeft;
        _noteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self.contentView addSubview:_noteLabel];
    }
    return _noteLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
        _timeLabel.textColor = UIColorFromRGB(0x9d9e9f);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (void)setNote:(GKNote *)note
{
    _note = note;
    
    [self.imageView sd_setImageWithURL:_note.entityChiefImage_240x240 placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xF0F0F0) andSize:CGSizeMake(90., 90.)]];
    self.noteLabel.text = _note.text;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_note.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    NSInteger x = 7;
//    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
//        x = 6;
//    }
//    else{
//        x = 8;
//    }
    
    [paragraphStyle setLineSpacing:x];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_note.text length])];
    self.noteLabel.attributedText = attributedString;
    
    
    /**
     *  设置发布时间
     */
    NSDate * date =  [NSDate dateWithTimeIntervalSince1970:_note.createdTime];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString fontAwesomeIconStringForEnum:FAClockO], [date stringWithFormat:@"Y-M-d"]];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0., 0., 80., 80.);
    self.imageView.deFrameLeft = 16.;
    
    self.noteLabel.frame = CGRectMake(0., 0., kScreenWidth - 120., 70.);
    self.noteLabel.deFrameLeft = self.imageView.deFrameRight + 5;
    
    self.timeLabel.frame = CGRectMake(0., 0., 100., 20.);
    self.timeLabel.deFrameBottom = self.contentView.deFrameHeight - 5.;
    self.timeLabel.deFrameRight = self.contentView.deFrameRight - 16.;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xebebeb).CGColor);
    CGContextSetLineWidth(context, kSeparateLineWidth);
    CGContextMoveToPoint(context, 0., self.deFrameHeight);
    CGContextAddLineToPoint(context, kScreenWidth, self.deFrameHeight);
    CGContextStrokePath(context);
    
}


@end