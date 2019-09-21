//
//  LivesView.h
//  WhackADrink
//
//  Created by Alec Bettinson on 12/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LivesView : UIView

@property (nonatomic, assign) NSInteger numberOfLives;
@property (nonatomic, assign, readonly) NSInteger currentLives;


- (void)removeLife;

@end
