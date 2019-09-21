//
//  GameCenterManager.h
//  PGGameCoreTest
//
//  Created by Alec Bettinson on 22/01/2013.
//  Copyright (c) 2013 Matt Davenport. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotificationAchievementEarned @"AchievementEarned"
#define kNotificationAchievementProgress @"AchievementProgress"

@class GKLeaderboard;

@interface GameCenterManager : NSObject

@property (atomic, readonly) BOOL userAuthenticated;

@property (atomic, readonly) BOOL leaderboardLoaded;
@property (atomic, readonly) BOOL achievementsLoaded;

@property (nonatomic, assign) BOOL useCustomAchievementInterface;

@property (nonatomic, assign) BOOL showAchievementProgress;

+ (GameCenterManager *)sharedInstance;

- (void)initialiseManager;

- (void)authenticateLocalUser;

//Fetches the leaderboard for a specific ID. Pass nil for the default leaderboard.
- (UIViewController *)leaderboardViewControllerForID:(NSString *)leaderboardID;

- (GKLeaderboard *)leaderboardForID:(NSString *)leaderboardID friendsOnly:(BOOL)friendsOnly;

- (void)reportScore:(NSInteger)score forLeaderboardID:(NSString *)leaderboardID;

- (UIViewController *)achievementController;

- (void)resetAchievementProgress;
- (void)completeAchievement:(NSString *)achievementID;
- (void)updateAchievementProgress:(NSString *)achievementID percentComplete:(CGFloat)percentage;

@end
