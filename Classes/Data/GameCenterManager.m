//
//  GameCenterManager.m
//  PGGameCoreTest
//
//  Created by Alec Bettinson on 22/01/2013.
//  Copyright (c) 2013 Matt Davenport. All rights reserved.
//

#import "GameCenterManager.h"
#import "AppDelegate.h"
#import <GameKit/GameKit.h>

#define kKeyFailedAchievements @"FailedAchievements"
#define kKeyFailedScoreUpdate  @"FailedScoreUpdate"

@interface GameCenterManager() <GKGameCenterControllerDelegate>

@property (strong) NSArray *leaderboards;
@property (strong) NSArray *achievements;

@end

@implementation GameCenterManager

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _achievementsLoaded = NO;
        _leaderboardLoaded = NO;
        _useCustomAchievementInterface = NO;
        _showAchievementProgress = NO;
                
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
        
    }
    return self;
}

- (void)initialiseManager
{
    [self authenticateLocalUser];
}

- (void)presentViewControllerfromAppDelegate:(UIViewController *)controller
{
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Auth

- (void)authenticateLocalUser
{
    if([GKLocalPlayer localPlayer].authenticated == YES)
    {
        return;
    }
    
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:(^(UIViewController* viewController, NSError *error) {
        //CR: Not clear what this does, you should add comments in with what you intend to do on the error handling
        if(!error && viewController)
        {
            [self presentViewControllerfromAppDelegate:viewController];
        }
        else if(error)
        {
            NSLog(@"error authenticating %@", error);
        }
    })];
}

- (void)authenticationChanged
{
	//CR: Can probably avoid these if blocks?
    if([GKLocalPlayer localPlayer].isAuthenticated && !_userAuthenticated)
    {
        _userAuthenticated = YES;
        [self loadAchievementInfo];
        [self loadLeaderboardInfo];
        [self checkFailedReports];
    }
    else if(![GKLocalPlayer localPlayer].isAuthenticated && _userAuthenticated)
    {
        _userAuthenticated = NO;
    }
}

#pragma mark - Leaderboard

- (void)loadLeaderboardInfo
{
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        if(error != nil)
        {
           // NSLog(@"Error loading leaderboard info");
        }
        else
        {
            _leaderboardLoaded = YES;
            self.leaderboards = [NSArray arrayWithArray:leaderboards];
        }
    }];
}

- (UIViewController *)leaderboardViewControllerForID:(NSString *)leaderboardID
{
    if(!_userAuthenticated)
    {
        [self authenticateLocalUser];
        return nil;
    }
    
    GKGameCenterViewController *leaderboardController = [[GKGameCenterViewController alloc] init];
    leaderboardController.gameCenterDelegate = self;
    leaderboardController.viewState = GKGameCenterViewControllerStateLeaderboards;
    leaderboardController.leaderboardIdentifier = leaderboardID;
    
    return leaderboardController;
}

- (void)reportScore:(NSInteger)score forLeaderboardID:(NSString *)leaderboardID
{
    GKScore *aScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardID];
    aScore.value = (int64_t)score;
    aScore.context = 0;
    
    [GKScore reportScores:@[aScore] withCompletionHandler:^(NSError *error) {
        if(error != nil)
        {
            NSLog(@"error reporting score for leaderboard %@: %@", leaderboardID, [error localizedDescription]);
            [self scoreSendFailed:aScore];
        }
        else
        {
            NSLog(@"%lld score added for leaderboard = %@", aScore.value, leaderboardID);
        }
    }];
}

- (GKLeaderboard *)leaderboardForID:(NSString *)leaderboardID friendsOnly:(BOOL)friendsOnly
{
    if(!_leaderboardLoaded)
    {
        [self loadLeaderboardInfo];
        return nil;
    }
    
    for(GKLeaderboard *leaderboard in self.leaderboards)
    {
        if([leaderboard.identifier caseInsensitiveCompare:leaderboardID] == NSOrderedSame)
        {
            leaderboard.timeScope = GKLeaderboardTimeScopeAllTime;
            
            if(friendsOnly)
            {
                leaderboard.playerScope = GKLeaderboardPlayerScopeFriendsOnly;
            }
            else
            {
                leaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
            }
            
            return leaderboard;
        }
    }
    
    return nil;
}

#pragma mark - Achievements

- (void)loadAchievementInfo
{
    if(!_userAuthenticated)
    {
        return;
    }
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if(error != nil)
        {
            _achievementsLoaded = NO;
            NSLog(@"error loading achievements");
        }
        else if(achievements != nil)
        {
            _achievementsLoaded = YES;
            self.achievements = [NSArray arrayWithArray:achievements];
        }
    }];
}

- (BOOL)checkForCompletedAchievement:(GKAchievement *)achievement
{
    if(achievement == nil || self.achievements == nil || ![self.achievements count] > 0)
    {
        return NO;
    }
    
    for(GKAchievement *loadedAchiements in self.achievements)
    {        
        if([loadedAchiements.identifier isEqualToString:achievement.identifier])
        {
            return YES;
        }
    }

    return NO;
}

- (UIViewController *)achievementController
{
    if(!_userAuthenticated)
    {
        [self authenticateLocalUser];
        return nil;
    }
    
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    gameCenterController.gameCenterDelegate = self;
    gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
    
    return gameCenterController;
}

- (void)resetAchievementProgress
{
    if(!_userAuthenticated)
    {
        return;
    }
    
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
         if(error != nil)
         {
             NSLog(@"Error resetting achievement");
         }
     }];
}

- (void)completeAchievement:(NSString *)achievementID
{
    [self updateAchievementProgress:achievementID percentComplete:100.0f];
}

- (void)updateAchievementProgress:(NSString *)achievementID percentComplete:(CGFloat)percentage
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementID];
    
    if(achievement && ![self checkForCompletedAchievement:achievement])
    {
        achievement.showsCompletionBanner = !self.useCustomAchievementInterface;
        achievement.percentComplete = percentage;
                        
        if(achievement.completed)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAchievementEarned object:achievement];
        }
        else if(_showAchievementProgress)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAchievementProgress object:achievement];
        }
        
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if(error != nil)
            {
                NSLog(@"Error updating achievement for ID:%@ %@", achievementID, error);
                [self achievementSendFailed:achievement];
            }
        }];
    }
    else
    {
        NSLog(@"Achievement %@ nil or completed", achievementID);
    }
}

#pragma mark - GameCenterViewController Delegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    gameCenterViewController.delegate = nil;
	
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Error Handling

- (void)checkFailedReports
{
    NSMutableArray *achievementsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedAchievements];
    NSMutableArray *scoresArray = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedScoreUpdate];
    
    if(achievementsArray != nil)
    {
        [self attemptAchievementUpload];
    }
    
    if(scoresArray != nil)
    {
        [self attemptScoreUpload];
    }
}

- (void)achievementSendFailed:(GKAchievement *)achievement
{
    NSData *achievementData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedAchievements];
	
    NSMutableArray *achievementsArray = [self arrayFromData:achievementData];
    
    if(achievementsArray != nil)
    {
        [achievementsArray addObject:achievement];
    }
    else
    {
        achievementsArray = [[NSMutableArray alloc] initWithObjects:achievement, nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self dataFromArray:achievementsArray] forKey:kKeyFailedAchievements];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self attemptAchievementUpload];
}

- (void)attemptAchievementUpload
{
    NSData *achievementData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedAchievements];
    NSMutableArray *achievementsArray = [NSMutableArray arrayWithArray:[self arrayFromData:achievementData]];

    if(![achievementsArray count] > 0)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyFailedAchievements];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GKAchievement reportAchievements:achievementsArray withCompletionHandler:^(NSError *error) {
         if (error != nil)
         {
             NSLog(@"Error in reporting achievements: %@", error);
             
             if([[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedAchievements] != nil)
             {
                 NSData *defaultsData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedAchievements];
                 NSMutableArray *achievementsFromDefaults = [self arrayFromData:defaultsData];
                 [achievementsArray addObjectsFromArray:achievementsFromDefaults];
             }
             
             [[NSUserDefaults standardUserDefaults] setObject:[self dataFromArray:achievementsArray] forKey:kKeyFailedAchievements];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             [self performSelector:@selector(attemptAchievementUpload) withObject:nil afterDelay:30];
         }
     }];
}

- (void)scoreSendFailed:(GKScore *)score
{
    NSData *scoreData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedScoreUpdate];
	
    NSMutableArray *scoreArray = [self arrayFromData:scoreData];
    
    if(scoreArray != nil)
    {
        [scoreArray addObject:score];
    }
    else
    {
        scoreArray = [[NSMutableArray alloc] initWithObjects:score, nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[self dataFromArray:scoreArray] forKey:kKeyFailedScoreUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self attemptScoreUpload];
}

- (void)attemptScoreUpload
{
    NSData *scoreData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedScoreUpdate];
    NSMutableArray *scoreArray = [self arrayFromData:scoreData];
    
    if(![scoreArray count] > 0)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyFailedScoreUpdate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GKScore reportScores:scoreArray withCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            NSLog(@"Error in reporting achievements: %@", error);
            
            if([[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedScoreUpdate] != nil)
            {
                NSData *defaultsData = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyFailedScoreUpdate];
                NSMutableArray *scoresFromDefaults = [self arrayFromData:defaultsData];
                [scoreArray addObjectsFromArray:scoresFromDefaults];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[self dataFromArray:scoreArray] forKey:kKeyFailedScoreUpdate];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSelector:@selector(attemptScoreUpload) withObject:nil afterDelay:30];
        }
    }];
}

//CR: These don't belong here, we're just replacing 1 line for 1 line, either use the KeyedArchiver in the code, or add these to some kind of Util class
#pragma mark - Helpers

- (NSMutableArray *)arrayFromData:(NSData *)data
{
    return [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

- (NSData *)dataFromArray:(NSMutableArray *)array
{
    return [NSKeyedArchiver archivedDataWithRootObject:array];
}

#pragma mark - Singleton

+ (GameCenterManager *)sharedInstance
{
    static GameCenterManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameCenterManager alloc] init];
    });
    return sharedInstance;
}

@end
