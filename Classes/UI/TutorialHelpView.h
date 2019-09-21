//
//  TutorialHelpView.h
//  WhackADrink
//
//  Created by Alec Bettinson on 14/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialHelpView : UIView

@property (nonatomic, assign) CGFloat arrowWidth;

- (id)initWithText:(NSString *)text;
- (CGSize)sizeOfView;

@end
