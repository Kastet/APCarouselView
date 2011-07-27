//
//  CarouselViewDemoViewController.m
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CarouselViewDemoViewController.h"

@implementation CarouselViewDemoViewController

@synthesize dataSourceArray = _dataSourceArray;

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (void)dealloc {
    [_carouselView release];
    [_dataSourceArray release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
	[_removeSelectedButton setEnabled:NO];
	[_removeSelectedButtonFade setEnabled:NO];
	[_removeSelectedButtonTop setEnabled:NO];
	[_removeSelectedButtonBottom setEnabled:NO];
	
    _carouselView = [[CarouselView alloc] initWithFrame:CGRectMake(10, 200, 738, 200) 
                                             dataSource:self 
                                               delegate:self];
    
    _carouselView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	self.dataSourceArray = [NSMutableArray array];
	
	[self.view addSubview:_carouselView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        _carouselView.willRotateCalled = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    _carouselView.willRotateCalled = NO;

    [_carouselView setNeedsLayout];
    [_carouselView layoutIfNeeded];
}

#pragma mark - Carousel DataSource

- (NSInteger)numberOfColumns {

    return [_dataSourceArray count];
}

- (CarouselViewCell *)carouselView:(CarouselView *)carouselView cellForColumnAtIndex:(NSInteger)index {
    
    CarouselViewCell *cell = [carouselView dequeueReusableCell];
    UILabel *label = nil;
    UIView *view = nil;
    
    if (cell == nil) {
        cell = [[[CarouselViewCell alloc] init] autorelease];
        
        view = [[[UIView alloc] initWithFrame:CGRectMake(2, 2, 186, 196)] autorelease];
        view.backgroundColor = [UIColor greenColor];
        [cell addSubview:view];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 90, 100, 20)] autorelease];
		label.tag = 1;
        [cell addSubview:label];		
    }

	for (UIView *subView in cell.subviews) {
		if (subView.tag == 1) {
			((UILabel *)subView).text = [_dataSourceArray objectAtIndex:index];
		}
	}

    return cell;
}

#pragma mark - CarouselView Delegate

- (void)carouselView:(CarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index {
	[_removeSelectedButton setEnabled:YES];
	[_removeSelectedButtonFade setEnabled:YES];
	[_removeSelectedButtonTop setEnabled:YES];
	[_removeSelectedButtonBottom setEnabled:YES];
}

#pragma - Helper Methods

- (NSString *)randomString {	
	NSMutableString *randomString = [NSMutableString stringWithCapacity:10];

	for (int i=0; i<10; i++) {
		[randomString appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
	}
	
	return randomString;
}

#pragma mark - IBActions

- (IBAction)cleanRecyclePool {
    [_carouselView cleanCellsRecyclePool];
}

- (void)addColumnWithAnimation:(APCarouselViewColumnAnimation)animation
{
	NSNumber *index = [NSNumber numberWithInt:0];
	NSString *newObj = [self randomString];
	[_dataSourceArray insertObject:newObj atIndex:[index intValue]];
	[_carouselView insertColumnsAtIndexes:[NSArray arrayWithObject:index] withColumnAnimation:animation];
}

- (IBAction)addColumn {
	[self addColumnWithAnimation:APCarouselViewColumnAnimationNone];
}

- (IBAction)addColumnFade {
	[self addColumnWithAnimation:APCarouselViewColumnAnimationFade];
}

- (IBAction)addColumnTop {
	[self addColumnWithAnimation:APCarouselViewColumnAnimationTop];
}

- (IBAction)addColumnBottom {
	[self addColumnWithAnimation:APCarouselViewColumnAnimationBottom];
}

- (IBAction)addMultipleColumnsFade {
	NSMutableArray *array = [NSMutableArray array];
	
	for (int i = 0; i < 5; i++) {
		NSString *newObj = [self randomString];
		[_dataSourceArray insertObject:newObj atIndex:0];
		[array addObject:[NSNumber numberWithInt:i]];
	}
	
	[_carouselView insertColumnsAtIndexes:array withColumnAnimation:APCarouselViewColumnAnimationFade];
}

- (void)removeSelectedColumnWithAnimation:(APCarouselViewColumnAnimation)animation {
	NSNumber *selectedIndex = [NSNumber numberWithInt:[_carouselView indexOfSelectedCell]];
	[_dataSourceArray removeObjectAtIndex:[selectedIndex intValue]];
	[_carouselView deleteColumnsAtIndexes:[NSArray arrayWithObject:selectedIndex] withColumnAnimation:animation];
	
	[_removeSelectedButton setEnabled:NO];
	[_removeSelectedButtonFade setEnabled:NO];
	[_removeSelectedButtonTop setEnabled:NO];
	[_removeSelectedButtonBottom setEnabled:NO];
}

- (IBAction)removeSelectedColumn {
	[self removeSelectedColumnWithAnimation:APCarouselViewColumnAnimationNone];
}

- (IBAction)removeSelectedColumnFade {
	[self removeSelectedColumnWithAnimation:APCarouselViewColumnAnimationFade];
}

- (IBAction)removeSelectedColumnTop {
	[self removeSelectedColumnWithAnimation:APCarouselViewColumnAnimationTop];
}

- (IBAction)removeSelectedColumnBottom {
	[self removeSelectedColumnWithAnimation:APCarouselViewColumnAnimationBottom];
}

- (IBAction)removeMultipleColumnsFade {
	if ([_dataSourceArray count] < 3) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Data" 
														message:@"Need at least 3 columns to be able to delete multiple" 
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	NSMutableArray *array = [NSMutableArray array];
	
	for (int i = 0; i < 3; i++) {
		[_dataSourceArray removeObjectAtIndex:0];
		[array addObject:[NSNumber numberWithInt:i]];
	}
	
	[_carouselView deleteColumnsAtIndexes:array withColumnAnimation:APCarouselViewColumnAnimationFade];
	
}

@end
