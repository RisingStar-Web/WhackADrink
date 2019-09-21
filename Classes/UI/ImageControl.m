//
//  ImageControl.m
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "ImageControl.h"

@interface ImageControl()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.bounds = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    self.imageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
    [self layoutSubviews];
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
