//
//  PlayView.m
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "PlayView.h"

@implementation PlayView

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"PlayView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        self.layer.cornerRadius = 5.f;
    }
    return self;
}


- (IBAction)playPressed:(id)sender {
    [self.delegate playPressed];
}

@end
