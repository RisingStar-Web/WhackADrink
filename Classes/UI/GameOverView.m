//
//  GameOverView.m
//  WhackADrink
//
//  Created by Alec Bettinson on 12/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "GameOverView.h"

@implementation GameOverView

- (id)init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"GameOverView" owner:self options:nil] objectAtIndex:0];
    if (self) {
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)displayed
{
    [self performSelector:@selector(showMenuOptions) withObject:nil afterDelay:0.5];
}

- (void)showMenuOptions
{
    self.startNewGameButton.enabled = YES;
    self.leaderboardButton.enabled = YES;
    self.mainMenuButton.enabled = YES;
}

- (IBAction)newGamePressed:(id)sender
{
    [self.delegate gameOverViewNewGame:self];
}

- (IBAction)mainMenuPressed:(id)sender
{
    [self.delegate gameOverViewMainMenu:self];
}

- (IBAction)leaderboardPressed:(id)sender
{
    [self.delegate leaderboardPressed:self];
}

@end
