//
//  CarouselViewCell.h
//  CarouselViewDemo
//
//  Created by kastet on 14.06.11.
//  Copyright 2011 Alterplay. All rights reserved.
//  www.alterplay.com

@protocol CarouselViewCellDelegate <NSObject>

- (void)clickedCellAtIndex:(NSInteger)index;

@end

@interface CarouselViewCell : UIView {
    UIView *_selectedBackgroundView;
}

@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL selected;
@property (nonatomic, assign) id<CarouselViewCellDelegate> delegate;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;


@end
