//
//  TutorialViewController.m
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "TutorialViewController.h"
#import "GamePanelViewController.h"
#import "TutorialHelpView.h"
#import "PlayView.h"
#import "GameViewController.h"

@interface TutorialViewController () <GamePanelViewControllerDelegate, PlayViewDelegate>

@property (nonatomic, weak) GamePanelViewController *panelViewController;

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, strong) TutorialHelpView *helpView;

@property (nonatomic, assign) NSInteger helpIteration;

@end

@implementation TutorialViewController

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
    
    self.backgroundImageView.image = [UIImage imageNamed:@"background"];
    
    self.score = 0;
    self.helpIteration = 0;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"panelEmbedSegue"])
    {
        self.panelViewController = (GamePanelViewController *)segue.destinationViewController;
        self.panelViewController.delegate = self;
    }
}

#pragma mark - GameManagement

- (void)startGame
{
    self.score = 0;
    [self showHelp];
}

- (void)showHelp
{
    if (self.helpIteration == 0) {
        [self.panelViewController showPopupWithType:0 atIndex:IS_IPAD ? 5 : 3];
        [self displayHelpWithString:NSLocalizedString(@"Single tap these.", nil)];
    } else if (self.helpIteration == 1) {
        [self.panelViewController showPopupWithType:1 atIndex:IS_IPAD ? 5 : 3];
        [self displayHelpWithString:NSLocalizedString(@"Double tap these.", nil)];
    } else if (self.helpIteration == 2) {
        [self.panelViewController showPopupWithType:2 atIndex:IS_IPAD ? 5 : 3];
        [self displayHelpWithString:NSLocalizedString(@"Avoid tapping these.\n(Except for now)", nil)];
    } else if (self.helpIteration == 3) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"TutorialShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        PlayView *playView = [[PlayView alloc] init];
        playView.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame), 320, 110);
        playView.delegate = self;
        playView.center = CGPointMake(self.view.center.x, playView.center.y);
        [self.view addSubview:playView];
        [UIView animateWithDuration:0.2 animations:^{
            playView.frame = CGRectMake(playView.frame.origin.x, CGRectGetMaxY(self.view.frame) - 100, 320, 110);
        }];
    }
}

- (void)displayHelpWithString:(NSString *)text
{
    self.helpView = [[TutorialHelpView alloc] initWithText:text];
    if (IS_IPAD) {
        self.helpView.arrowWidth = 15;
        self.helpView.frame = CGRectMake(kPopupWidth, CGRectGetMidX(self.panelViewController.view.frame) - ((kPopupHeight / 2) + 30), [self.helpView sizeOfView].width, 50);
    } else {
        self.helpView.frame = CGRectMake(kPopupWidth, CGRectGetMidX(self.panelViewController.view.frame) + (kPopupHeight / 2), [self.helpView sizeOfView].width, 40);
    }
    self.helpView.alpha = 0;
    [self.view addSubview:self.helpView];
    
    [UIView animateWithDuration:0.2
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         self.helpView.alpha = 1;
                     }
                     completion:nil];
}

- (void)dismissHelpView
{
    if (self.helpView.layer.animationKeys) {
        [self.helpView.layer removeAllAnimations];
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.helpView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.helpView removeFromSuperview];
                         self.helpView = nil;
                         self.helpIteration++;
                         [self performSelector:@selector(showHelp) withObject:nil afterDelay:0.5];
                     }];
}

- (void)endGame
{
    [self.panelViewController stopGame];
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
}


#pragma mark - GamePanelDelegate

- (void)gamePanel:(GamePanelViewController *)viewController updatedScore:(NSInteger)score
{
    self.score += score;
    [self dismissHelpView];
}

#pragma mark - PlayViewDelegate

- (void)playPressed
{
    NSString *device = IS_IPAD == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"Main_%@", device] bundle:nil];
    
    if (self.type == TutorialTypeLives) {
        GameViewController *gameViewController = [storyboard instantiateViewControllerWithIdentifier:@"gameViewController"];
        [gameViewController setGameType:GameTypeLives];
        NSMutableArray *controllers = [[self.navigationController viewControllers] mutableCopy];
        [controllers removeLastObject];
        [controllers addObject:gameViewController];
        
        [self.navigationController setViewControllers:controllers animated:NO];
        
    } else if (self.type == TutorialTypeTimed60 || self.type == TutorialTypeTimed120) {
        GameViewController *gameViewController = [storyboard instantiateViewControllerWithIdentifier:@"gameViewController"];
        [gameViewController setGameType:self.type == TutorialTypeTimed60 ? GameTypeTimed60 : GameTypeTimed120];
        NSMutableArray *controllers = [[self.navigationController viewControllers] mutableCopy];
        [controllers removeLastObject];
        [controllers addObject:gameViewController];
        
        [self.navigationController setViewControllers:controllers animated:NO];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
