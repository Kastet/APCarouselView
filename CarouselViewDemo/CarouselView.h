//
//  CarouselView.h
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

#import "CarouselViewCell.h"

@class CarouselView;

@protocol CarouselViewDelegate <NSObject>

- (void)carouselView:(CarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index;

@end

@protocol CarouselViewDataSource <NSObject>

- (NSInteger)numberOfColonms;
- (CarouselViewCell *)carouselView:(CarouselView *)carouselView cellForColomnAtIndex:(NSInteger)index;

@end


@interface CarouselView : UIView <UIScrollViewDelegate, CarouselViewCellDelegate> {

    UIScrollView *_scrollView;
    
    NSInteger _numberOfColonms;
    NSInteger _numberOfVisibleCells;
    
    NSMutableSet *_visibleCells;
    NSMutableSet *_recyclePool;
}

@property (nonatomic, assign) id<CarouselViewDataSource> dataSource;
@property (nonatomic, assign) id<CarouselViewDelegate> delegate;
@property (nonatomic) CGFloat colomnWidth;

// flag specifies if - (void)willRotateToInterfaceOrientation:duration: caused method - (void)layoutSubviews
// need to fix sharp removing invisible cells 
@property (nonatomic) BOOL willRotateCalled;

@property (nonatomic, readonly) NSInteger indexOfSelectedCell;

- (id)initWithFrame:(CGRect)frame dataSource:(id)dataSource delegate:(id)delegate;
- (CarouselViewCell *)dequeueReusableCell;
- (void)cleanCellsRecyclePool;

- (NSArray *)visibleCells;


@end
