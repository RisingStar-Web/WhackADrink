//
//  MenuViewController.h
//  WhackADrink
//
//  Created by Alec Bettinson on 12/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//


@interface MenuViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *timed60Button;
@property (weak, nonatomic) IBOutlet UIButton *timed120Button;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
- (IBAction)timedPressed:(id)sender;
- (IBAction)livesPressed:(id)sender;
- (IBAction)leaderboardsPressed:(id)sender;

@end
