//
//  Constants.h
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#define kPopupSpacing 2
#define kDontTapProbability 2
#define kDoubleTapProbability 2

#define kBaseSingleTapScore 10
#define kBaseDoubleTapScore 30
#define kBaseDontTapScore -20

#define kBasePopupInterval 1.6
#define kPopupTimeReductionConstant 0.2f
#define kMinimumPopupInterval 0.3
#define kDifficultyIterationThreshold 10
#define kDifficultyIterationThresholdTimed60 7

#define k60TimerLength 60
#define k120TimerLength 120

#define kPopupWidth (IS_IPAD ? 200 : 102)
#define kPopupHeight (IS_IPAD ? 220 : 125)

#define kNumberOfHoles (IS_IPAD ? 15 : 9)
#define kHolesPerLine (IS_IPAD ? 5 : 3)

#define kLeaderboardTimed60 @"co.tapbox.whackadrink.timed60"
#define kLeaderboardTimed120 @"co.tapbox.whackadrink.timed120"
#define kLeaderboardLives @"co.tapbox.whackadrink.lives"
