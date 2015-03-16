//
//  RadioButton.m
//  orange
//
//  Created by 谢家欣 on 15/3/16.
//  Copyright (c) 2015年 sensoro. All rights reserved.
//

#import "RadioButton.h"

@interface RadioButton()
{
    NSMutableArray* _sharedLinks;
}
@end

@implementation RadioButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if(![[self allTargets] containsObject:self]) {
            [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

-(void) awakeFromNib
{
    if(![[self allTargets] containsObject:self]) {
        [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    // 'self' should be the first target
    if(![[self allTargets] containsObject:self]) {
        [super addTarget:self action:@selector(onTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    [super addTarget:target action:action forControlEvents:controlEvents];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void) onTouchUpInside
{
    [self setSelected:YES distinct:YES sendControlEvent:YES];
}

-(void) setGroupButtons:(NSArray *)buttons
{
    if(!_sharedLinks) {
        for(RadioButton* rb in buttons) {
            if(rb->_sharedLinks) {
                _sharedLinks = rb->_sharedLinks;
                break;
            }
        }
        if(!_sharedLinks) {
            _sharedLinks = [[NSMutableArray alloc] initWithCapacity:[buttons count]+1];
        }
    }
    
    BOOL (^btnExistsInList)(NSArray*, RadioButton*) = ^(NSArray* list, RadioButton* rb){
        for(NSValue* v in list) {
            if([v nonretainedObjectValue]==rb) {
                return YES;
            }
        }
        return NO;
    };
    
    if(!btnExistsInList(_sharedLinks, self)) {
        [_sharedLinks addObject:[NSValue valueWithNonretainedObject:self]];
    }
    
    for(RadioButton* rb in buttons) {
        if(rb->_sharedLinks!=_sharedLinks) {
            if(!rb->_sharedLinks) {
                rb->_sharedLinks = _sharedLinks;
            } else {
                for(NSValue* v in rb->_sharedLinks) {
                    RadioButton* vrb = [v nonretainedObjectValue];
                    if(!btnExistsInList(_sharedLinks, vrb)) {
                        [_sharedLinks addObject:v];
                        vrb->_sharedLinks = _sharedLinks;
                    }
                }
            }
        }
        if(!btnExistsInList(_sharedLinks, rb)) {
            [_sharedLinks addObject:[NSValue valueWithNonretainedObject:rb]];
        }
    }
}

-(NSArray*) groupButtons
{
    if([_sharedLinks count]) {
        NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:[_sharedLinks count]];
        for(NSValue* v in _sharedLinks) {
            [buttons addObject:[v nonretainedObjectValue]];
        }
        return buttons;
    }
    return nil;
}

-(RadioButton*) selectedButton
{
    if([self isSelected]) {
        return self;
    } else {
        for(NSValue* v in _sharedLinks) {
            RadioButton* rb = [v nonretainedObjectValue];
            if([rb isSelected]) {
                return rb;
            }
        }
    }
    return nil;
}

-(void) setSelected:(BOOL)selected
{
    [self setSelected:selected distinct:YES sendControlEvent:NO];
}

-(void) setButtonSelected:(BOOL)selected sendControlEvent:(BOOL)sendControlEvent
{
    BOOL valueChanged = (self.selected != selected);
    [super setSelected:selected];
    if(valueChanged && sendControlEvent) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void) setSelected:(BOOL)selected distinct:(BOOL)distinct sendControlEvent:(BOOL)sendControlEvent
{
    [self setButtonSelected:selected sendControlEvent:sendControlEvent];
    
    if( distinct && (selected || [_sharedLinks count]==2) )
    {
        selected = !selected;
        for(NSValue* v in _sharedLinks) {
            RadioButton* rb = [v nonretainedObjectValue];
            if(rb!=self) {
                [rb setButtonSelected:selected sendControlEvent:sendControlEvent];
            }
        }
    }
}


-(void) deselectAllButtons
{
    for(NSValue* v in _sharedLinks) {
        RadioButton* rb = [v nonretainedObjectValue];
        [rb setButtonSelected:NO sendControlEvent:NO];
    }
}

-(void) setSelectedWithTag:(NSInteger)tag
{
    if(self.tag == tag) {
        [self setSelected:YES distinct:YES sendControlEvent:NO];
    } else {
        for(NSValue* v in _sharedLinks) {
            RadioButton* rb = [v nonretainedObjectValue];
            if(rb.tag == tag) {
                [rb setSelected:YES distinct:YES sendControlEvent:NO];
                break;
            }
        }
    }
}

- (void)dealloc
{
    for(NSValue* v in _sharedLinks) {
        if([v nonretainedObjectValue]==self) {
            [_sharedLinks removeObjectIdenticalTo:v];
            break;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xebebeb).CGColor);
    CGContextSetLineWidth(context, kSeparateLineWidth);
    CGContextMoveToPoint(context, 30., self.frame.size.height - kSeparateLineWidth);
    CGContextAddLineToPoint(context, kScreenWidth, self.frame.size.height - kSeparateLineWidth);
    
    
    CGContextStrokePath(context);
}

@end