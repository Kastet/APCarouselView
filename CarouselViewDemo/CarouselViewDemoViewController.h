//
//  CarouselViewDemoViewController.h
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CarouselView.h"
#import "CarouselViewCell.h"

@interface CarouselViewDemoViewController : UIViewController <CarouselViewDataSource, CarouselViewDelegate> {
    CarouselView *_carouselView;
    NSMutableArray *_dataSourceArray;
	IBOutlet UISegmentedControl *_animationSegmentedControl;
	IBOutlet UIButton *_removeSelectedButton;
}

@property (nonatomic, retain) NSMutableArray *dataSourceArray;

- (IBAction)cleanRecyclePool;
- (IBAction)addColumn;
- (IBAction)addMultipleColumns;
- (IBAction)removeSelectedColumn;
- (IBAction)removeMultipleColumns;

@end
