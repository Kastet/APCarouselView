//
//  CarouselViewDemoViewController.m
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CarouselViewDemoViewController.h"

@implementation CarouselViewDemoViewController


- (void)dealloc {
    [_carouselView release];
    [_daraSourceArray release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _carouselView = [[CarouselView alloc] initWithFrame:CGRectMake(10, 200, 738, 200) 
                                             dataSource:self 
                                               delegate:self];
    
    _carouselView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
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

- (NSInteger)numberOfColonms {
    return 110;
}

- (CarouselViewCell *)carouselView:(CarouselView *)carouselView cellForColomnAtIndex:(NSInteger)index {
    
    CarouselViewCell *cell = [carouselView dequeueReusableCell];
    UILabel *label = nil;
    UIView *view = nil;
    
    if (cell == nil) {
        cell = [[[CarouselViewCell alloc] init] autorelease];
        
        view = [[[UIView alloc] initWithFrame:CGRectMake(2, 2, 186, 196)] autorelease];
        view.backgroundColor = [UIColor greenColor];
        [cell addSubview:view];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(50, 90, 100, 20)] autorelease];
        [cell addSubview:label];
    }

    label.text = [NSString stringWithFormat:@"Cell %d", index];
    
    return cell;
}

#pragma mark - CarouselView Delegate

- (void)carouselView:(CarouselView *)carouselView didSelectCellAtIndex:(NSInteger)index {
    NSLog(@"index = %d", index);
}

- (IBAction)cleanRecyclePool {
    [_carouselView cleanCellsRecyclePool];
}


@end
