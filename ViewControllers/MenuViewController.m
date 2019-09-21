//
//  MenuViewController.m
//  WhackADrink
//
//  Created by Alec Bettinson on 12/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "MenuViewController.h"
#import "GameViewController.h"
#import "TutorialViewController.h"
#import "GameCenterManager.h"

@interface MenuViewController ()

@property (nonatomic, assign) TutorialType tutorialType;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.backgroundImageView.image = [UIImage imageNamed:@"background.png"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tutorialType = TutorialTypeMain;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ButtonEvents

- (IBAction)timedPressed:(id)sender
{
    if (![self tutorialDisplayed]) {
        self.tutorialType = sender == self.timed60Button ? TutorialTypeTimed60 : TutorialTypeTimed120;
        [self performSegueWithIdentifier:@"tutorialPushSegue" sender:self];
        return;
    }
    
    [self performSegueWithIdentifier:@"timedPushSegue" sender:sender];
}

- (IBAction)livesPressed:(id)sender
{
    if (![self tutorialDisplayed]) {
        self.tutorialType = TutorialTypeLives;
        [self performSegueWithIdentifier:@"tutorialPushSegue" sender:self];
        return;
    }
    
    [self performSegueWithIdentifier:@"livesPushSegue" sender:self];
}

- (IBAction)leaderboardsPressed:(id)sender
{    
    UIViewController *viewController = [[GameCenterManager sharedInstance] leaderboardViewControllerForID:kLeaderboardLives];
    
    if (viewController) {
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"You seem to have GameCenter disabled for this application. Please enable it and try again", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"timedPushSegue"])
    {
        GameViewController *viewController = segue.destinationViewController;
        [viewController setGameType:sender == self.timed60Button ? GameTypeTimed60 : GameTypeTimed120];
    }
    else if ([segue.identifier isEqualToString:@"livesPushSegue"])
    {
        GameViewController *viewController = segue.destinationViewController;
        [viewController setGameType:GameTypeLives];
    }
    else if ([segue.identifier isEqualToString:@"tutorialPushSegue"])
    {
        TutorialViewController *viewController = segue.destinationViewController;
        viewController.type = self.tutorialType;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)tutorialDisplayed
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"TutorialShown"] boolValue];
}


@end
