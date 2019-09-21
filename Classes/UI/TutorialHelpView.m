//
//  TutorialHelpView.m
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "TutorialHelpView.h"

#define kSpacing 4

@interface TutorialHelpView()

@property (nonatomic, strong) UILabel *label;

@end

@implementation TutorialHelpView

- (id)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        self.arrowWidth = 10;
        
        self.backgroundColor = [UIColor clearColor];
        
        // Initialization code
        _label = [[UILabel alloc] init];
        _label.text = text;
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 0;
        _label.font = IS_IPAD ? [UIFont applicationFontWithSize:20.f] : [UIFont applicationFontWithSize:14.f];
        [self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = CGRectMake(self.arrowWidth + kSpacing, 0, self.frame.size.width - (self.arrowWidth + (kSpacing * 2)), self.frame.size.height);
}

- (CGSize)sizeOfView
{
    CGSize size = [self.label.text sizeWithAttributes:@{NSFontAttributeName : self.label.font}];
    
    size.width += (self.arrowWidth + kSpacing) * 2;
    
    return size;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.f alpha:0.9f].CGColor);
    
    CGContextMoveToPoint(context, 0, rect.size.height / 2);
    CGContextAddLineToPoint(context, self.arrowWidth, self.arrowWidth);
    CGContextAddLineToPoint(context, self.arrowWidth, 0);
    CGContextAddLineToPoint(context, rect.size.width - self.arrowWidth, 0);
    CGContextAddLineToPoint(context, rect.size.width  - self.arrowWidth, rect.size.height);
    CGContextAddLineToPoint(context, self.arrowWidth, rect.size.height);
    CGContextAddLineToPoint(context, self.arrowWidth, rect.size.height - self.arrowWidth);
    CGContextAddLineToPoint(context, 0, rect.size.height / 2);
    
    CGContextFillPath(context);
}


@end
