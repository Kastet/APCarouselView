//
//  CarouselView.h
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

#import "CarouselViewCell.h"

@class CarouselView;

typedef enum {
	APCarouselViewColumnAnimationNone,
	APCarouselViewColumnAnimationFade,
	APCarouselViewColumnAnimationTop,
	APCarouselViewColumnAnimationBottom
} APCarouselViewColumnAnimation;


@protocol CarouselViewDelegate <NSObject>

- (void)carouselView:(CarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index;

@end

@protocol CarouselViewDataSource <NSObject>

- (NSInteger)numberOfColumnsForCarouselView:(CarouselView *)carouselView;
- (CarouselViewCell *)carouselView:(CarouselView *)carouselView cellForColumnAtIndex:(NSInteger)index;

@end


@interface CarouselView : UIView <UIScrollViewDelegate, CarouselViewCellDelegate> {

    UIScrollView *_scrollView;
    
    NSInteger _numberOfColumns;
    NSInteger _numberOfVisibleCells;
    
    NSMutableSet *_visibleCells;
    NSMutableSet *_recyclePool;
}

@property (nonatomic, assign) id<CarouselViewDataSource> dataSource;
@property (nonatomic, assign) id<CarouselViewDelegate> delegate;
@property (nonatomic) CGFloat columnWidth;

// flag specifies if - (void)willRotateToInterfaceOrientation:duration: caused method - (void)layoutSubviews
// need to fix sharp removing invisible cells 
@property (nonatomic) BOOL willRotateCalled;

@property (nonatomic, readonly) NSInteger indexOfSelectedCell;

- (id)initWithFrame:(CGRect)frame dataSource:(id)dataSource delegate:(id)delegate;
- (CarouselViewCell *)dequeueReusableCell;
- (void)cleanCellsRecyclePool;

- (void)insertColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(APCarouselViewColumnAnimation)animation;
- (void)deleteColumnsAtIndexes:(NSArray *)indexes withColumnAnimation:(APCarouselViewColumnAnimation)animation;

- (NSArray *)visibleCells;


@end
