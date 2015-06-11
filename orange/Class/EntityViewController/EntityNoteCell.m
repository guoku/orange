//
//  EntityNoteCell.m
//  orange
//
//  Created by 谢家欣 on 15/6/8.
//  Copyright (c) 2015年 guoku.com. All rights reserved.
//

#import "EntityNoteCell.h"

static inline NSRegularExpression * ParenthesisRegularExpression() {
    static NSRegularExpression *_parenthesisRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _parenthesisRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(#|＃)([のA-Z0-9a-z\u4e00-\u9fa5_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _parenthesisRegularExpression;
}
static inline NSRegularExpression * UrlRegularExpression() {
    static NSRegularExpression *_urlRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _urlRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"(http(s)?://([A-Z0-9a-z._=&?-]*(/)?)*)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _urlRegularExpression;
}

@interface EntityNoteCell ()<RTLabelDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView * avatarImageView;
@property (strong, nonatomic) RTLabel * nameLabel;
@property (strong, nonatomic) UILabel * starLabel;
@property (strong, nonatomic) RTLabel * contentLabel;
@property (strong, nonatomic) UIButton * pokeBtn;
@property (strong, nonatomic) UIButton * commentBtn;
@property (strong, nonatomic) UILabel * timeLabel;

@end

@implementation EntityNoteCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf8f8f8);
        self.contentView.backgroundColor = UIColorFromRGB(0xffffff);
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        pan.delegate = self;
        [self.contentView addGestureRecognizer:pan];
        
        UISwipeGestureRecognizer * swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipAction:)];
        swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//
//        UISwipeGestureRecognizer * swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipAction:)];
//        swipRight.direction = UISwipeGestureRecognizerDirectionRight;
//        
//        [self.contentView addGestureRecognizer:swipLeft];
//        [self.contentView addGestureRecognizer:swipRight];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver];
}

- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.userInteractionEnabled = YES;
        _avatarImageView.layer.cornerRadius = 18.;
        _avatarImageView.layer.masksToBounds = YES;
        //        _avatarImageView.backgroundColor = [UIColor redColor];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(avatarBtnAction:)];
        [_avatarImageView addGestureRecognizer:tap];
        
        [self.contentView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

- (RTLabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.paragraphReplacement = @"";
        _nameLabel.lineSpacing = 7.0;
        _nameLabel.delegate = self;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (RTLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[RTLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.paragraphReplacement = @"";
        _contentLabel.lineSpacing = 7.0;
        
        _contentLabel.delegate = self;
        [_contentLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        _contentLabel.textColor = UIColorFromRGB(0x414243);
        [self.contentView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)starLabel
{
    if (!_starLabel) {
        _starLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _starLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
        _starLabel.textAlignment = NSTextAlignmentRight;
        //        _starLabel.hidden = YES;
        _starLabel.backgroundColor = [UIColor clearColor];
        _starLabel.textColor = UIColorFromRGB(0xFF9600);
        _starLabel.text = [NSString stringWithFormat:@"%@",[NSString fontAwesomeIconStringForEnum:FAStar]];
        [self.contentView addSubview:_starLabel];
    }
    return _starLabel;
}

- (UIButton *)pokeBtn
{
    if (!_pokeBtn) {
        _pokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pokeBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
        _pokeBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_pokeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_pokeBtn setTitleColor:UIColorFromRGB(0x9d9e9f) forState:UIControlStateNormal];
        [_pokeBtn setTitleColor:UIColorFromRGB(0x427ec0) forState:UIControlStateSelected];
        [_pokeBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,0, 0, 0)];
        
        [_pokeBtn addTarget:self action:@selector(pokeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_pokeBtn];
    }
    return _pokeBtn;
}

- (UIButton *)commentBtn
{
    if (!_commentBtn) {
        _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commentBtn.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:14];
        _commentBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_commentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_commentBtn setTitleColor:UIColorFromRGB(0x9d9e9f) forState:UIControlStateNormal];
        [_commentBtn setTitleColor:UIColorFromRGB(0x427ec0) forState:UIControlStateSelected];
        [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0,0, 0, 0)];
        
        [_commentBtn addTarget:self action:@selector(commentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _commentBtn.hidden = YES;
        [self.contentView addSubview:_commentBtn];
    }
    return _commentBtn;
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

#pragma mark - set note data
- (void)setNote:(GKNote *)note
{
    if (_note) {
        [self removeObserver];
    }
    _note = note;
    [self addObserver];
    //    DDLogVerbose(@"cell note creator %@", _note.creator.nickname);
    
    [self.avatarImageView sd_setImageWithURL:_note.creator.avatarURL placeholderImage:[UIImage imageWithColor:UIColorFromRGB(0xf1f1f1) andSize:CGSizeMake(36., 36.)]];
    
    self.nameLabel.text = [NSString stringWithFormat:@"<a href='user:%lu'><font face='Helvetica-Bold' color='^427ec0' size=14>%@ </font></a>", _note.creator.userId, _note.creator.nickname];
    
    if(_note.text != nil)
    {
        NSMutableString * resultText = [NSMutableString stringWithString:self.note.text];
        NSRegularExpression *regexp =  ParenthesisRegularExpression();
        NSArray *array = [regexp matchesInString: self.note.text
                                         options: 0
                                           range: NSMakeRange( 0, [self.note.text length])];
        
        NSUInteger i = 0;
        NSUInteger j = 0;
        for (NSTextCheckingResult *match in array)
        {
            j = match.range.location+i;
            
            NSString * a = [NSString stringWithFormat:@"<a href='tag:%@'><font face='Helvetica' color='^427ec0'>",[[self.note.text substringWithRange:NSMakeRange(match.range.location+1,match.range.length-1)]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [resultText insertString:a atIndex:j];
            NSString * b = [NSString stringWithFormat:@"</font></a>"];
            j = match.range.length+j+a.length;
            [resultText insertString:b atIndex:j];
            
            i = i + b.length + a.length;
        }
        NSRegularExpression *urlregexp =  UrlRegularExpression();
        NSArray *urlarray = [urlregexp matchesInString: resultText
                                               options: 0
                                                 range: NSMakeRange( 0, [resultText length])];
        i = 0;
        for (NSTextCheckingResult *match in urlarray)
        {
            j = match.range.location+i;
            NSString * a = [NSString stringWithFormat:@"<a href='%@'><font face='Helvetica' color='^427ec0'>",[resultText substringWithRange:NSMakeRange(match.range.location,match.range.length)]];
            [resultText insertString:a atIndex:j];
            NSString * b = [NSString stringWithFormat:@"</font></a>"];
            j = match.range.length+j+a.length;
            [resultText insertString:b atIndex:j];
            
            i = i + b.length + a.length;
            
        }
        
        [self.contentLabel setText:resultText];
    }
    
    self.starLabel.hidden = YES;
    if (self.note.marked) {
        self.starLabel.hidden = NO;
    }
    
    self.pokeBtn.selected = self.note.poked;
    if (self.note.pokeCount == 0) {
        [self.pokeBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsOUp]  forState:UIControlStateNormal];
    } else {
        [self.pokeBtn setTitle:[NSString stringWithFormat:@"%@ %lu",[NSString fontAwesomeIconStringForEnum:FAThumbsOUp],self.note.pokeCount] forState:UIControlStateNormal];
    }
    
    if ([Passport sharedInstance].user.user_state == GKUserBlockState && k_isLogin) {
        self.commentBtn.hidden = YES;
    } else {
        self.commentBtn.hidden = NO;
    }
    
    if(self.note.commentCount == 0) {
        [self.commentBtn setTitle:[NSString stringWithFormat:@"%@",[NSString fontAwesomeIconStringForEnum:FACommentO]] forState:UIControlStateNormal];
    } else {
        [self.commentBtn setTitle:[NSString stringWithFormat:@"%@ %ld",[NSString fontAwesomeIconStringForEnum:FACommentO],self.note.commentCount] forState:UIControlStateNormal];
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForEnum:FAClockO],[self.note.createdDate stringWithDefaultFormat]];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarImageView.frame = CGRectMake(20., 16., 36., 36.);
    self.nameLabel.frame = CGRectMake(0., 0., 200., 20.);
    self.nameLabel.deFrameTop = self.avatarImageView.deFrameTop;
    self.nameLabel.deFrameLeft = self.avatarImageView.deFrameRight + 10;
    
    self.starLabel.frame = CGRectMake(0., 0., 160., 20.);
    self.starLabel.center = self.nameLabel.center;
    self.starLabel.deFrameRight = kScreenWidth - 16.;
    
    self.contentLabel.frame = CGRectMake(0, 0., kScreenWidth - 78., 20);
    self.contentLabel.deFrameHeight = self.contentLabel.optimumSize.height + 5.f;
    self.contentLabel.deFrameTop = self.nameLabel.deFrameBottom + 10.;
    self.contentLabel.deFrameLeft = self.avatarImageView.deFrameRight + 10;
    
    self.pokeBtn.frame = CGRectMake(0., 0., 50., 20.);
    self.pokeBtn.deFrameLeft = self.contentLabel.deFrameLeft;
    self.pokeBtn.deFrameBottom = self.contentView.deFrameHeight - 16;
    
    self.commentBtn.frame = CGRectMake(0., 0., 50., 20.);
    self.commentBtn.center = self.pokeBtn.center;
    self.commentBtn.deFrameLeft = self.pokeBtn.deFrameRight + 15.;
//    self.commentBtn.deFrameBottom = self.contentView.deFrameHeight - 26.;
    
    self.timeLabel.frame = CGRectMake(0, 0, 160, 20);
    self.timeLabel.center = self.commentBtn.center;
    self.timeLabel.deFrameRight = kScreenWidth - 16.;
    
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xebebeb).CGColor);
    CGContextSetLineWidth(context, kSeparateLineWidth);
    
    CGContextMoveToPoint(context, 0., self.frame.size.height - kSeparateLineWidth);
    CGContextAddLineToPoint(context, kScreenWidth, self.frame.size.height - kSeparateLineWidth);
    
    CGContextStrokePath(context);
}

+ (CGFloat)height:(GKNote *)note
{
    RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0., kScreenWidth - 78., 20)];
    label.paragraphReplacement = @"";
    label.lineSpacing = 7.0;
    label.text = [NSString stringWithFormat:@"<font face='Helvetica' color='^777777' size=14>%@</font>", note.text];
    return label.optimumSize.height + 96.;
}

#pragma mark - button action
- (void)avatarBtnAction:(id)sender
{
    DDLogInfo(@"avatar action");
//    [[OpenCenterController sharedOpenCenterController] openUser:self.note.creator];
    [[OpenCenter sharedOpenCenter] openUser:self.note.creator];
}

- (void)pokeBtnAction:(id)sender
{
    DDLogInfo(@"poke note action");
//    if (_delegate && [_delegate respondsToSelector:@selector(tapPokeNoteBtn:Note:)])
//    {
//        [_delegate tapPokeNoteBtn:sender Note:self.note];
//    }
    [API pokeWithNoteId:self.note.noteId state:!self.pokeBtn.selected success:^(NSString *entityId, NSUInteger noteId, BOOL poked) {
        
        if (poked == self.pokeBtn.selected) {
            
        }
        else if (poked) {
            self.note.pokeCount = self.note.pokeCount+1;
        } else {
            self.note.pokeCount = self.note.pokeCount-1;
        }
        self.note.poked = poked;
        
        [AVAnalytics event:@"poke note" attributes:@{@"note": @(self.note.noteId), @"status":@"success"} durations:(int)self.note.pokeCount];
        [MobClick event:@"poke note" attributes:@{@"note": @(self.note.noteId), @"status":@"success"} counter:(int)self.note.pokeCount];
    } failure:^(NSInteger stateCode) {
        [AVAnalytics event:@"poke note" attributes:@{@"note":@(self.note.noteId), @"status":@"failure"}];
        [MobClick event:@"poke note" attributes:@{@"note":@(self.note.noteId), @"status":@"failure"}];
    }];
}

- (void)commentBtnAction:(id)sender
{
    DDLogInfo(@"comment action");
    [[OpenCenter sharedOpenCenter] openNoteComment:self.note];
//    [[OpenCenterController sharedOpenCenterController] openNoteComment:self.note];
}

#pragma mark - <RTLabelDelegate>
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    //    DDLogInfo(@"tap %@", rtLabel);
    NSArray  * array= [[url absoluteString] componentsSeparatedByString:@":"];
    if([array[0] isEqualToString:@"http"])
    {
        [[OpenCenter sharedOpenCenter] openWebWithURL:url];
        //        GKWebVC * vc =  [GKWebVC linksWebViewControllerWithURL:url];
//        WebViewController * vc = [[WebViewController alloc] initWithURL:url];
//        [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
    }
    if([array[0] isEqualToString:@"tag"])
    {
        [[OpenCenter sharedOpenCenter] openTagWithName:[array[1]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] User:self.note.creator];
//        TagViewController * vc = [[TagViewController alloc]init];
//        vc.tagName = [array[1]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        vc.user = self.note.creator;
//        if (kAppDelegate.activeVC.navigationController) {
//            [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
//        }
    }
    if([array[0] isEqualToString:@"user"])
    {
        GKUser * user = [GKUser modelFromDictionary:@{@"userId":@([array[1] integerValue])}];
        [[OpenCenter sharedOpenCenter] openUser:user];
//        GKUser * user = [GKUser modelFromDictionary:@{@"userId":@([array[1] integerValue])}];
//        UserViewController * vc = [[UserViewController alloc]init];
//        vc.user = user;
//        if (kAppDelegate.activeVC.navigationController) {
//            [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
//        }
    }
    if([array[0] isEqualToString:@"entity"])
    {
        GKEntity * entity = [GKEntity modelFromDictionary:@{@"entityId":@([array[1] integerValue])}];
        [[OpenCenter sharedOpenCenter] openEntity:entity];
//        EntityViewController * vc = [[EntityViewController alloc]init];
//        vc.entity = entity;
//        if (kAppDelegate.activeVC.navigationController) {
//            [kAppDelegate.activeVC.navigationController pushViewController:vc animated:YES];
//        }
    }
}

#pragma mark - Swip
- (void)swipAction:(id)sender
{
    UISwipeGestureRecognizer *swip = (UISwipeGestureRecognizer *)sender;
    if ([swip direction] == UISwipeGestureRecognizerDirectionLeft) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = CGRectMake(-80, 0., self.deFrameWidth, self.deFrameHeight);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = CGRectMake(0., 0., self.deFrameWidth, self.deFrameHeight);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)panAction:(id)sender
{
//    DDLogInfo(@"%@", sender);
    UIPanGestureRecognizer * recognizer = (UIPanGestureRecognizer *)sender;
    CGPoint translatedPoint = [recognizer translationInView:self.contentView];
//    DDLogInfo(@"offset %f", recognizer.view.deFrameLeft);
//    if (recognizer.view.deFrameLeft <= 0) {
        CGFloat x = recognizer.view.center.x + translatedPoint.x;
        recognizer.view.center = CGPointMake(x, recognizer.view.center.y);
//    }
//    CGFloat y = recognizer.view.center.y + translatedPoint.y;
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.contentView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{

//    DDLogInfo(@"return %f", translatedPoint.y);
    return YES;
}

#pragma mark - Note model KVO
- (void)addObserver
{
    [_note addObserver:self forKeyPath:@"pokeCount" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_note addObserver:self forKeyPath:@"poked" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
}

- (void)removeObserver
{
    [_note removeObserver:self forKeyPath:@"pokeCount"];
    [_note removeObserver:self forKeyPath:@"poked"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"pokeCount"]) {
        if (self.note.pokeCount > 0) {
            [self.pokeBtn setTitle:[NSString stringWithFormat:@"%@ %lu",[NSString fontAwesomeIconStringForEnum:FAThumbsOUp],self.note.pokeCount] forState:UIControlStateNormal];
        }
        else
        {
            [self.pokeBtn setTitle:[NSString fontAwesomeIconStringForEnum:FAThumbsOUp]  forState:UIControlStateNormal];
        }
    }
    if ([keyPath isEqualToString:@"poked"]) {
        self.pokeBtn.selected = self.note.poked;
    }
}

@end
