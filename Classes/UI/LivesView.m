//
//  LivesView.m
//  WhackADrink
//
//  Created by Alec Bettinson on 12/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "LivesView.h"

@interface LivesView()

@property (nonatomic, strong) NSMutableArray *livesView;

@end

@implementation LivesView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

    
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat xPos = 0;
    
    for (UIImageView *imageView in self.livesView)
    {
        imageView.frame = CGRectMake(xPos, -2, imageView.image.size.width, imageView.image.size.height);
        xPos += imageView.frame.size.width;
    }
    
    CGRect selfFrame = self.frame;
    selfFrame.size.width = xPos;
    
    self.frame = selfFrame;
    
}

- (void)setNumberOfLives:(NSInteger)numberOfLives
{
    _numberOfLives = numberOfLives;
    _currentLives = numberOfLives;
    [self populateLivesView];
}

- (void)populateLivesView
{
    if (self.livesView) {
        [self.livesView makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.livesView = [NSMutableArray array];
    
    for (int i=0; i < self.numberOfLives; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
        [self addSubview:imageView];
        [self.livesView addObject:imageView];
    }
}

- (void)removeLife
{
    UIImageView *imageView = [self.livesView objectAtIndex:_currentLives - 1];
    [imageView setImage:[UIImage imageNamed:@"heart-empty"]];
    _currentLives--;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
