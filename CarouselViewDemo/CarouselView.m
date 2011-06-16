//
//  CarouselView.m
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

#import "CarouselView.h"


@interface CarouselView()

- (CarouselViewCell *)visibleCellForIndex:(NSInteger)index;

@end

@implementation CarouselView

@synthesize dataSource = _dataSource, delegate = _delegate;
@synthesize colomnWidth = _colomnWidth;
@synthesize willRotateCalled;
@synthesize indexOfSelectedCell = _indexOfSelectedCell;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame dataSource:(id)dataSource delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        
        _visibleCells = [NSMutableSet new];
        _recyclePool = [NSMutableSet new];
        
        self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        _dataSource = dataSource;
        _delegate = delegate;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.contentSize = self.bounds.size;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_scrollView];
        
        // defaults values
        _numberOfColonms = 0;
        _colomnWidth = 192;
        _numberOfVisibleCells = ceil(_scrollView.frame.size.width / _colomnWidth);
        _indexOfSelectedCell = -1;
        
        if ([_dataSource respondsToSelector:@selector(numberOfColonms)]) {
            _numberOfColonms = [_dataSource numberOfColonms];
            _scrollView.contentSize = CGSizeMake(_colomnWidth * _numberOfColonms, self.frame.size.height);
        }
    }
    return self;
}

#pragma mark - Memory 

- (void)dealloc {
    [_recyclePool release];
    [_visibleCells release];
    self.dataSource = nil;
    self.delegate = nil;
    
    [_scrollView release];
    
    [super dealloc];
}

#pragma mark - Private

- (CarouselViewCell *)visibleCellForIndex:(NSInteger)index {
    
    for (CarouselViewCell *cell in _visibleCells) {
        if (cell.index == index) {
            //           NSLog(@"returned visible cell for index %d", index);
            return cell;
        }
    }
    return nil;
}

- (void)layoutSubviews {
    
    if (self.willRotateCalled == YES)
        return;
    
    // remove cells that are no longer visible
    for(UIView *v in _visibleCells) {
        if (_scrollView.contentOffset.x > 0 && !CGRectIntersectsRect(v.frame, _scrollView.bounds)) {
            [_recyclePool addObject:v];
            [v removeFromSuperview];
        }
    }
    [_visibleCells minusSet:_recyclePool];
    
    if (_numberOfColonms == 0) 
        return;
    
    // tile missing cells
    NSUInteger firstColumn = floorf( CGRectGetMinX(_scrollView.bounds) / _colomnWidth );
    firstColumn = MAX(firstColumn, 0);
    NSUInteger lastColumn = floorf( (CGRectGetMaxX(_scrollView.bounds) - 1) / _colomnWidth ) + 1;
    
    lastColumn = MIN(lastColumn, _numberOfColonms);
    
    
    // cells layout peforms inside animation block with zero-duration to exclude animation inside animation block that inited by rotation event
    [UIView animateWithDuration:0 
                          delay:0 
                        options:UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         for(int column = firstColumn; column < lastColumn; ++column) {
                             
                             CarouselViewCell *cell = [self visibleCellForIndex:column];
                             if (!cell) {
                                 cell = [self.dataSource carouselView:self cellForColomnAtIndex:column];
                                 cell.index = column;
                                 cell.delegate = self;
                                 
                                 BOOL selected = (column == _indexOfSelectedCell); 
                                 cell.selected = selected;
                                 
                                 [_visibleCells addObject:cell];
                                 [_scrollView addSubview:cell];
                                 [_scrollView sendSubviewToBack:cell];
                             }
                             cell.frame = CGRectMake(column * _colomnWidth, 0, _colomnWidth, self.bounds.size.height);
                         }
                         
                     } 
                     completion:nil];
}

#pragma mark - Public

- (CarouselViewCell *)dequeueReusableCell {
    
    CarouselViewCell* cell = [_recyclePool anyObject];
	if (cell) {
		[[cell retain] autorelease];
		[_recyclePool removeObject:cell];
	}
	return cell;
}

- (void)cleanCellsRecyclePool {
    NSLog(@"%d cells removed from recyclePool", [_recyclePool count]);
    [_recyclePool removeAllObjects];
}

- (NSArray *)visibleCells {
    return [_visibleCells allObjects];
}
   
   
#pragma mark - CarouselViewCell Delegate

- (void)clickedCellAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(carouselView:didSelectCellAtIndex:)]) {
        
        if (_indexOfSelectedCell != index) {

            // select tapped cell 
            CarouselViewCell *newSelectedCell = [self visibleCellForIndex:index];
            [newSelectedCell setSelected:YES animated:NO];
            
            // deselect previous selected cell 
            CarouselViewCell *previousSelectedCell = [self visibleCellForIndex:_indexOfSelectedCell];
            [previousSelectedCell setSelected:NO animated:NO];
            
            _indexOfSelectedCell = index;   
        }
        
        [_delegate carouselView:self didSelectCellAtIndex:index];
    }
}


@end
