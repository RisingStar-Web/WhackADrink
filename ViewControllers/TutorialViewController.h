//
//  TutorialViewController.h
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TutorialTypeTimed60 = 0,
    TutorialTypeTimed120,
    TutorialTypeLives,
    TutorialTypeMain
} TutorialType;

@interface TutorialViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, assign) TutorialType type;

@end
