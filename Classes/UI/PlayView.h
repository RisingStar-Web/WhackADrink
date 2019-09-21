//
//  PlayView.h
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayViewDelegate <NSObject>

- (void)playPressed;

@end

@interface PlayView : UIView

@property (nonatomic, weak) id<PlayViewDelegate> delegate;

- (IBAction)playPressed:(id)sender;

@end
