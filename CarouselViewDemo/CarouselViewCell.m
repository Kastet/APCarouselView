//
//  CarouselViewCell.m
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

#import "CarouselViewCell.h"


@implementation CarouselViewCell

@synthesize index;
@synthesize selected = _selected;
@synthesize delegate = _delegate;

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        _selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _selectedBackgroundView.backgroundColor = [UIColor blackColor];
        _selectedBackgroundView.alpha = 0.0f;
        [self addSubview:_selectedBackgroundView];        
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc {
    [_selectedBackgroundView release];
    self.delegate = nil;
    [super dealloc];
}

#pragma mark - Private

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _selectedBackgroundView.frame = self.bounds;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self bringSubviewToFront:_selectedBackgroundView];
    if (!_selected)
        _selectedBackgroundView.alpha = 0.5f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_selected)
        _selectedBackgroundView.alpha = 0.0f;
    
    [_delegate clickedCellAtIndex:self.index];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _selectedBackgroundView.alpha = 0.0f;
}

#pragma mark - Public

- (void)setSelected:(BOOL)selected {
    float newAlpha = selected ? 0.5f : 0.0f;
    _selectedBackgroundView.alpha = newAlpha;
    _selected = selected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    float duration = animated ? 0.3f : 0.0f;
    
    [UIView animateWithDuration:duration 
                     animations:^(void) {
                         [self setSelected:selected];
                     }];
}


@end
