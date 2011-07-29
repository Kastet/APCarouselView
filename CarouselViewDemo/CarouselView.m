//
//  CarouselView.m
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

#import "CarouselView.h"


@interface CarouselView()

- (void)resizeScrollView;
- (void)setNumberOfColumnsFromDelegate;
- (CarouselViewCell *)visibleCellForIndex:(NSInteger)index;

@end

@implementation CarouselView

@synthesize dataSource = _dataSource, delegate = _delegate;
@synthesize columnWidth = _columnWidth;
@synthesize willRotateCalled;
@synthesize indexOfSelectedCell = _indexOfSelectedCell;

static float ANIMATION_SPEED = 0.3;

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
        _numberOfColumns = 0;
        _columnWidth = 192;
        _indexOfSelectedCell = -1;
        
		[self setNumberOfColumnsFromDelegate];
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

- (void)removeHiddenView:(UIView *)view
{
	if (_scrollView.contentOffset.x > 0 && !CGRectIntersectsRect(view.frame, _scrollView.bounds)) {
		[_recyclePool addObject:view];
		[view removeFromSuperview];
	}
}

- (void)resizeScrollView {

	_scrollView.contentSize = CGSizeMake(_columnWidth * _numberOfColumns, self.frame.size.height);
}

- (void)setNumberOfColumnsFromDelegate {

	if ([_dataSource respondsToSelector:@selector(numberOfColumnsForCarouselView:)]) {
		_numberOfColumns = [_dataSource numberOfColumnsForCarouselView:self];
		[self resizeScrollView];
	}
}

- (CarouselViewCell *)visibleCellForIndex:(NSInteger)index {

    for (CarouselViewCell *cell in _visibleCells) {
        if (cell.index == index) {
            //           NSLog(@"returned visible cell for index %d", index);
            return cell;
        }
    }
    return nil;
}

- (CarouselViewCell *)cellForIndex:(NSInteger)index {
	
	CarouselViewCell *cell = [self visibleCellForIndex:index];
	if (!cell) {
		cell = [self.dataSource carouselView:self cellForColumnAtIndex:index];
		cell.index = index;
		cell.delegate = self;
		
		BOOL selected = (index == _indexOfSelectedCell); 
		cell.selected = selected;
		
		[_visibleCells addObject:cell];
		[_scrollView addSubview:cell];
		[_scrollView sendSubviewToBack:cell];
	}
	
	return cell;
}

- (void)layoutSubviews {

    if (self.willRotateCalled == YES)
        return;
    
    // remove cells that are no longer visible
    for(UIView *v in _visibleCells) {
		[self removeHiddenView:v];
    }
    [_visibleCells minusSet:_recyclePool];
    
    if (_numberOfColumns == 0) 
        return;
    
    // tile missing cells
    NSUInteger firstColumn = floorf( CGRectGetMinX(_scrollView.bounds) / _columnWidth );
    firstColumn = MAX(firstColumn, 0);
	
    NSUInteger lastColumn = floorf( (CGRectGetMaxX(_scrollView.bounds) - 1) / _columnWidth ) + 1;
    lastColumn = MIN(lastColumn, _numberOfColumns);
    
    
    // cells layout peforms inside animation block with zero-duration to exclude animation inside animation block that inited by rotation event
    [UIView animateWithDuration:0 
                          delay:0 
                        options:UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         for(int column = firstColumn; column < lastColumn; ++column) {
                             CarouselViewCell *cell = [self cellForIndex:column];
                             cell.frame = CGRectMake(column * _columnWidth, 0, _columnWidth, self.bounds.size.height);
                         }
                         
                     } 
                     completion:nil];
}

- (void)slideCellsFromIndex:(NSInteger)index forInsert:(BOOL)insert completion:(void(^) (BOOL finished))block {
	
	NSInteger maxVisibleIndex = 0;
	CarouselViewCell *cell = [self visibleCellForIndex:index];
	NSMutableArray *cellsToMove = [NSMutableArray array];
	for (CarouselViewCell *visibleCell in _visibleCells) {
		if (visibleCell.frame.origin.x >= cell.frame.origin.x) {
			if (_indexOfSelectedCell == visibleCell.index) {
				_indexOfSelectedCell = (insert) ? visibleCell.index + 1 : visibleCell.index - 1;
			}
			visibleCell.index = (insert) ? visibleCell.index + 1 : visibleCell.index - 1;
			maxVisibleIndex = (visibleCell.index > maxVisibleIndex) ? visibleCell.index : maxVisibleIndex;
			[cellsToMove addObject:visibleCell];
		}
	}
	
	// Removing a cell?
	if (!insert)
	{
		// Do we have more cells off screen?
		if (_numberOfColumns > maxVisibleIndex + 1) {
			NSUInteger lastColumn = floorf( (CGRectGetMaxX(_scrollView.bounds) - 1) / _columnWidth );
			lastColumn = MIN(lastColumn, _numberOfColumns);
			
			CarouselViewCell *cell = [self cellForIndex:lastColumn];

			// Add cell to array of cells to move
			[cellsToMove addObject:cell];
			
			// Place cell just off the edge of the scrollView
			cell.frame = CGRectMake((lastColumn + 1) * _columnWidth , 0, _columnWidth, self.bounds.size.height);
		}
	}
	
	[UIView animateWithDuration:ANIMATION_SPEED
					 animations:^{
						 for (CarouselViewCell *cell in cellsToMove) {
							 CGRect fromFrame = cell.frame;
							 NSInteger newX = (insert) ? fromFrame.origin.x + _columnWidth : fromFrame.origin.x - _columnWidth;
							 CGRect toFrame = CGRectMake(newX, 0, _columnWidth, self.bounds.size.height);
							 cell.frame = toFrame;
						 }
					 }
					 completion:^(BOOL finished) {
						 if (block) block(finished);
						 for (UIView *view in cellsToMove) {
							 [self removeHiddenView:view];
						 }
					 }];
}

- (void)slideCellsFromIndex:(NSInteger)index forInsert:(BOOL)insert {

	[self slideCellsFromIndex:index forInsert:insert completion:nil];
}

- (void)animateCellAtIndex:(NSInteger)index animation:(APCarouselViewColumnAnimation)animation forInsert:(BOOL)insert completion:(void(^) (BOOL finished))block {
	
	CGRect hiddenRect;
	CGRect visibleRect;
	
	CarouselViewCell *cell;
	
	if (insert) {
		cell = [self cellForIndex:index];
	}
	else {
		cell = [self visibleCellForIndex:index];
	}
	
	// place new cell in appropriate column
	if (insert) {
		NSInteger column = 0;
		for (CarouselViewCell *visibleCell in _visibleCells)
		{
			if (visibleCell.index < index) {
				column++;
			}
		}
		cell.frame = CGRectMake(column * _columnWidth, 0, _columnWidth, self.bounds.size.height);
	}
			
	switch (animation) {
		case APCarouselViewColumnAnimationFade:
			if (insert) {
				cell.alpha = 0.0;
				cell.frame = visibleRect;
			}
			
			[UIView animateWithDuration:ANIMATION_SPEED 
								  delay:0
								options:UIViewAnimationOptionAllowUserInteraction
							 animations:^{ 
								 cell.alpha = (insert) ? 1.0 : 0.0; 
							 } 
							 completion:^(BOOL finished) {
								 if (block) block(finished);
								 [self setNumberOfColumnsFromDelegate];
								 [self layoutSubviews];
							 }];
			break;
			
		case APCarouselViewColumnAnimationTop:
			hiddenRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y - self.bounds.size.height, _columnWidth, self.bounds.size.height);
			visibleRect = CGRectMake(cell.frame.origin.x, 0, _columnWidth, self.bounds.size.height);
			
			if (insert) {
				cell.alpha = 1.0;
				cell.frame = hiddenRect;
			}
			
			[UIView animateWithDuration:ANIMATION_SPEED
								  delay:0
								options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
							 animations:^{
								 cell.frame = (insert) ? visibleRect : hiddenRect;
							 } 
							 completion:^(BOOL finished){
								 if (block) block(finished);
								 [self setNumberOfColumnsFromDelegate];
								 [self layoutSubviews];
							 }];
			break;
			
		case APCarouselViewColumnAnimationBottom:
			hiddenRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + self.bounds.size.height, _columnWidth, self.bounds.size.height);
			visibleRect = CGRectMake(cell.frame.origin.x, 0, _columnWidth, self.bounds.size.height);
			
			if (insert) {
				cell.alpha = 1.0;
				cell.frame = hiddenRect;
			}
			
			[UIView animateWithDuration:ANIMATION_SPEED
								  delay:0
								options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
							 animations:^{
								 cell.frame = (insert) ? visibleRect : hiddenRect;
							 } 
							 completion:^(BOOL finished){
								 if (block) block(finished);
								 [self setNumberOfColumnsFromDelegate];
								 [self layoutSubviews];
							 }];
			break;
			
		default:
			if (block) block(YES);
			[self setNumberOfColumnsFromDelegate];
			[self layoutSubviews];
			break;
	}
}

- (void)animateCellAtIndex:(NSInteger)index animation:(APCarouselViewColumnAnimation)animation forInsert:(BOOL)insert {
	
	[self animateCellAtIndex:index animation:animation forInsert:insert completion:nil];
}

#pragma mark - UIViewController Methods

- (void)setNeedsDisplay {

	[super setNeedsDisplay];
	[self setNumberOfColumnsFromDelegate];
	[self layoutSubviews];
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

    [_recyclePool removeAllObjects];
}

- (NSArray *)visibleCells {
	
    return [_visibleCells allObjects];
}

- (void)insertColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(APCarouselViewColumnAnimation)animation
{
	// Multiple Inserts needs work
	for (NSNumber *index in indexes) {
		CarouselViewCell *cell = [self visibleCellForIndex:[index intValue]];
		
		if (cell) {
			[self slideCellsFromIndex:[index intValue] forInsert:YES completion:^(BOOL finished){ 
				[self animateCellAtIndex:[index intValue] animation:animation forInsert:YES];
			}];			
		}
		else
		{
			[self animateCellAtIndex:[index intValue] animation:animation forInsert:YES];
		}
	}
}

- (void)deleteColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(APCarouselViewColumnAnimation)animation
{
	
	// Multiple Deletes needs work
	for (NSNumber *index in indexes) {
		CarouselViewCell *cell = [self visibleCellForIndex:[index intValue]];
		if (cell) {
			if ([index intValue] == _indexOfSelectedCell) {
				_indexOfSelectedCell = -1;
			}
			
			[self animateCellAtIndex:[index intValue] 
						   animation:animation 
						   forInsert:NO 
						  completion:^(BOOL finished){
							  [cell removeFromSuperview];
							  cell.alpha = 1.0;
  							  _numberOfColumns--;
							  [self slideCellsFromIndex:[index intValue] forInsert:NO];
							  [_recyclePool addObject:cell];
							  [_visibleCells removeObject:cell];
						  }];
		}
	}
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