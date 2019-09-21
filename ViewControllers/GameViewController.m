//
//  GameViewController.m
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "GameViewController.h"
#import "GamePanelViewController.h"
#import "GameOverView.h"
#import "GameCenterManager.h"

@interface GameViewController () <GamePanelViewControllerDelegate, GameOverViewDelegate>

@property (nonatomic, weak) GamePanelViewController *panelViewController;

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger time;

@property (nonatomic, strong) NSTimer *gameTimer;

@property (nonatomic, assign) BOOL displayingLeaderboard;

@end

@implementation GameViewController

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

    self.time = 0;
    self.score = 0;
    self.displayingLeaderboard = NO;
    
    if (self.gameType == GameTypeLives)
    {
        self.timeLabel.hidden = YES;
        self.livesView.hidden = NO;
        self.livesView.numberOfLives = 3;
    }
    else if (self.gameType == GameTypeTimed60 || self.gameType == GameTypeTimed120)
    {
        self.timeLabel.hidden = NO;
        self.livesView.hidden = YES;
        self.time = self.timerLength;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.displayingLeaderboard)
    {
        [self startGame];
    }
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
        self.panelViewController.useShorterThreshold = self.gameType == GameTypeTimed60 ? YES : NO;
    }
}

#pragma mark - GameManagement

- (void)startGame
{
    if (self.gameType == GameTypeTimed60 || self.gameType == GameTypeTimed120)
    {
        self.timerLength = self.gameType == GameTypeTimed60 ? k60TimerLength : k120TimerLength;
        self.time = self.timerLength;
        [self startGameTimer];
    }
    else if (self.gameType == GameTypeLives)
    {
        self.livesView.numberOfLives = 3;
    }
    
    self.score = 0;
    [self.panelViewController startGame];
    
}

- (void)endGame
{
    [self cancelGameTimer];
    [self.panelViewController stopGame];
    
    [[GameCenterManager sharedInstance] reportScore:self.score forLeaderboardID:[self leaderboardForGameType]];
    
    GameOverView *gameOverView = [[GameOverView alloc] init];
    gameOverView.delegate = self;
    gameOverView.frame = self.view.frame;
    gameOverView.scoreLabel.text = [NSString stringWithFormat:@"%d", self.score];
    gameOverView.alpha = 0;
    [self.view addSubview:gameOverView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         gameOverView.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [gameOverView displayed];
                     }];
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
}

#pragma mark - GameTypeTimed

- (void)startGameTimer
{
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(iterateTimer) userInfo:nil repeats:YES];
}

- (void)cancelGameTimer
{
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
    }
}

- (void)iterateTimer
{
    self.time--;
    
    if (self.time <= 0) {
        [self endGame];
    }
}

- (void)setTime:(NSInteger)time
{
    _time = time;
    self.timeLabel.text = [NSString stringWithFormat:@"%d", time];
}

#pragma mark - GameTypeLives

- (void)removeLife
{
    [self.livesView removeLife];
    
    if (self.livesView.currentLives == 0)
    {
        [self endGame];
    }
}

#pragma mark - GamePanelDelegate

- (void)gamePanel:(GamePanelViewController *)viewController updatedScore:(NSInteger)score
{
    self.score += score;
    
    if (self.gameType == GameTypeLives && score < 0)
    {
        [self removeLife];
    }
}

#pragma mark - GameOverViewDelegate

- (void)gameOverViewMainMenu:(GameOverView *)gameOverView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)gameOverViewNewGame:(GameOverView *)gameOverView
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         gameOverView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [gameOverView removeFromSuperview];
                         [self startGame];
                     }];
}

- (void)leaderboardPressed:(GameOverView *)view
{
    self.displayingLeaderboard = YES;
    
    UIViewController *viewController = [[GameCenterManager sharedInstance] leaderboardViewControllerForID:[self leaderboardForGameType]];
    
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

#pragma mark - GameCenter

- (NSString *)leaderboardForGameType
{
    if (self.gameType == GameTypeLives) {
        return kLeaderboardLives;
    } else if (self.gameType == GameTypeTimed60) {
        return kLeaderboardTimed60;
    } else if (self.gameType == GameTypeTimed120) {
        return kLeaderboardTimed120;
    }
    
    return @"";
}

@end
