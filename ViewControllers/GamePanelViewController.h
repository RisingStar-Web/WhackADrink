//
//  GamePanelViewController.h
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GamePanelViewController;

@protocol GamePanelViewControllerDelegate <NSObject>

- (void)gamePanel:(GamePanelViewController *)viewController updatedScore:(NSInteger)score;

@end

@interface GamePanelViewController : UIViewController

@property (nonatomic, weak) id<GamePanelViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL useShorterThreshold;

- (void)startGame;
- (void)stopGame;
- (void)showPopupWithType:(NSInteger)type atIndex:(NSInteger)index;

@end
