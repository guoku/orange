//
//  EntityHeaderActionView.m
//  orange
//
//  Created by 谢家欣 on 15/8/9.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "EntityHeaderActionView.h"

@interface EntityHeaderActionView ()

@property (strong, nonatomic) UIButton *postBtn;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIView *H;
@end

@implementation EntityHeaderActionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
    }
    return self;
}

- (UIButton *)likeButton
{
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_likeButton setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
        [_likeButton setImage:[UIImage imageNamed:@"liked"] forState:UIControlStateSelected];
        _likeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(0., 0., 0., 10.)];
        [_likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.entity.isLiked) {
            _likeButton.selected = YES;
        }
        [self addSubview:_likeButton];
    }
    return _likeButton;
}

- (UIButton *)postBtn
{
    if (!_postBtn) {
        _postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_postBtn setImage:[UIImage imageNamed:@"note"] forState:UIControlStateNormal];
        [_postBtn setTitleColor:UIColorFromRGB(0x414243) forState:UIControlStateNormal];
        _postBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_postBtn setImageEdgeInsets:UIEdgeInsetsMake(0., 0., 0., 10.)];
        [_postBtn addTarget:self action:@selector(noteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_postBtn];
    }
    return _postBtn;
}


- (UIButton *)moreButton
{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.layer.masksToBounds = YES;
        _moreButton.layer.cornerRadius = 4;
        [_moreButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [_moreButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_moreButton setTitleEdgeInsets:UIEdgeInsetsMake(0,0, 0, 0)];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreButton];
    }
    return _moreButton;
}

- (void)setEntity:(GKEntity *)entity
{
    _entity = entity;
    self.likeButton.frame = CGRectMake(0, 3., 80., 44.);
    self.postBtn.frame = CGRectMake(0., 3.,  80., 44.);
    self.moreButton.frame = CGRectMake(0., 3., 80., 44.);
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.likeButton.center = CGPointMake(kScreenWidth * 3/6-80, self.deFrameHeight/2);
    self.postBtn.center = CGPointMake(kScreenWidth * 3/6, self.deFrameHeight/2);
    self.moreButton.center = CGPointMake(kScreenWidth * 3/6+80, self.deFrameHeight/2);
    self.H.deFrameBottom = self.deFrameHeight;
}

#pragma mark - button action
- (void)likeButtonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(tapLikeBtn:)])
    {
        [_delegate tapLikeBtn:sender];
    }
}

- (void)noteButtonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(tapPostNoteBtn:)])
    {
        [_delegate tapPostNoteBtn:sender];
    }
}

- (void)moreButtonAction:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(tapMoreBtn:)])
    {
        [_delegate tapMoreBtn:sender];
    }
}


@end
