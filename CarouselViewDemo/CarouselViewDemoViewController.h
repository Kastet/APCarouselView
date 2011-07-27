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
	IBOutlet UIButton *_removeSelectedButton;
	IBOutlet UIButton *_removeSelectedButtonFade;
	IBOutlet UIButton *_removeSelectedButtonTop;
	IBOutlet UIButton *_removeSelectedButtonBottom;
}

@property (nonatomic, retain) NSMutableArray *dataSourceArray;

- (IBAction)cleanRecyclePool;
- (IBAction)addColumn;
- (IBAction)addColumnFade;
- (IBAction)addColumnTop;
- (IBAction)addColumnBottom;
- (IBAction)addMultipleColumnsFade;
- (IBAction)removeSelectedColumn;
- (IBAction)removeSelectedColumnFade;
- (IBAction)removeSelectedColumnTop;
- (IBAction)removeSelectedColumnBottom;
- (IBAction)removeMultipleColumnsFade;

@end
