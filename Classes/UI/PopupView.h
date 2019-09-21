//
//  PopupView.h
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PopupTypeSingleTap = 0,
    PopupTypeDoubleTap,
    PopupTypeDontTap
} PopupType;

@class PopupView;

@protocol PopupViewDelegate <NSObject>

- (void)popupViewActivated:(PopupView *)view;

@end

@interface PopupView : UIView

@property (nonatomic, assign) PopupType type;

@property (nonatomic, weak) id<PopupViewDelegate> delegate;

@property (nonatomic, assign) BOOL canBeShown;
@property (nonatomic, assign) BOOL selectable;


+ (PopupView *)popupView;

- (void)popUp;
- (void)popDown;

- (void)holdUp;

- (void)reset;

@end
