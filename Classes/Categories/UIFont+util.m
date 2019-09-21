//
//  UIFont+util.m
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "UIFont+util.h"

@implementation UIFont (util)

+ (UIFont *)applicationFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"Helvetica-Light" size:size];
}

@end
