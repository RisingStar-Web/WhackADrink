//
//  PopupView.m
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "PopupView.h"
#import "ImageControl.h"

@interface PopupView()

@property (nonatomic, strong) NSTimer *dismissTimer;

@property (nonatomic, strong) ImageControl *popupImage;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UIView *overlay;

@property (nonatomic, assign) NSInteger touchCount;
@property (nonatomic, assign) NSInteger touchesRequired;

@property (nonatomic, strong) NSDictionary *imagesDict;

@end

@implementation PopupView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.clipsToBounds = YES;
        
        self.imagesDict = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ImageNames"];
        
        _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.imagesDict objectForKey:@"Background"]]];
        [self addSubview:_backgroundImage];
        
        _overlay = [[UIView alloc] init];
        [self addSubview:_overlay];
        
        _popupImage = [[ImageControl alloc] init];
        [_popupImage addTarget:self action:@selector(activated) forControlEvents:UIControlEventTouchDown];
        [_overlay addSubview:_popupImage];
        
        [self reset];
        [self addClippingMask];
    }
    return self;
}

+ (PopupView *)popupView
{
    PopupView *view = [[PopupView alloc] init];
    view.bounds = CGRectMake(0, 0, kPopupWidth, kPopupHeight);
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.overlay.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.popupImage.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)addClippingMask
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(kPopupWidth, 0)];
    [path addLineToPoint:CGPointMake(kPopupWidth, kPopupHeight - (IS_IPAD ? 50 : 26))];
    [path addCurveToPoint:CGPointMake(0, kPopupHeight - (IS_IPAD ? 50 : 26)) controlPoint1:CGPointMake(kPopupWidth/ 2, kPopupHeight - (IS_IPAD ? 20 : 10)) controlPoint2:CGPointMake(kPopupWidth / 2, kPopupHeight - (IS_IPAD ? 20 : 10))];
    [path closePath];

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(0, 0, kPopupWidth, kPopupHeight);
    layer.path = path.CGPath;

    self.overlay.layer.mask = layer;
}

#pragma mark - Display

- (void)popUp
{
    if (!self.canBeShown) {
        return;
    }
    
    self.selectable = YES;
    self.canBeShown = NO;
    
    CGRect upFrame = self.popupImage.frame;
    upFrame.origin.y = 0;
    
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:1.7f target:self selector:@selector(popDown) userInfo:nil repeats:NO];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.popupImage.frame = upFrame;

                     }
                     completion:nil];
}

- (void)popDown
{
    [self.popupImage.layer removeAllAnimations];
    
    CGRect downFrame = self.popupImage.frame;
    downFrame.origin.y = self.frame.size.height;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.popupImage.frame = downFrame;
                     }
                     completion:^(BOOL finished) {
                         [self reset];
                     }];
}


- (void)holdUp
{
    self.selectable = YES;
    self.canBeShown = NO;
    
    CGRect upFrame = self.popupImage.frame;
    upFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.popupImage.frame = upFrame;
                     }
                     completion:nil];
}

- (void)cancelTimers
{
    if (self.dismissTimer)
    {
        [self.dismissTimer invalidate];
        self.dismissTimer = nil;
    }
}

- (void)reset
{
    self.selectable = NO;
    self.canBeShown = YES;
}

- (void)activated
{
    if (!self.selectable) {
        return;
    }
    
    self.touchCount++;
    
    if (self.touchCount < self.touchesRequired)
    {
        self.popupImage.image = [UIImage imageNamed:[self.imagesDict objectForKey:@"DoubleTapHalf"]];
        return;
    }
    
    [self cancelTimers];
    
    self.selectable = NO;
    [self.delegate popupViewActivated:self];

    
    if (self.type == PopupTypeDontTap)
    {
        [self showError];
    }
    else
    {
        self.popupImage.image = [self emptyImageForType:self.type];
        [self popDown];
    }
}

- (void)showError
{
    self.popupImage.image = [UIImage imageNamed:[self.imagesDict objectForKey:@"DontTapError"]];
    [self performSelector:@selector(popDown) withObject:nil afterDelay:1];
}

#pragma mark - TypeManagement

- (void)setType:(PopupType)type
{
    _type = type;
    
    [self configurePopup];
}

#pragma mark - Popup Configuration

- (void)configurePopup
{
    self.popupImage.image = [self imageForType:self.type];
    
    self.touchCount = 0;
    
    if (self.type == PopupTypeSingleTap)
    {
        [self enableSingleTap];
    }
    else if (self.type == PopupTypeDoubleTap)
    {
        [self enableDoubleTap];
    }
    else if (self.type == PopupTypeDontTap)
    {
        [self enableDontTap];
    }
}

- (void)enableSingleTap
{
    self.touchesRequired = 1;
}

- (void)enableDoubleTap
{
    self.touchesRequired = 2;
}

- (void)enableDontTap
{
    self.touchesRequired = 1;
}

- (UIImage *)imageForType:(PopupType)type
{
    NSString *key = nil;
    
    if (type == PopupTypeSingleTap)
    {
        key = @"SingleTap";
    }
    else if (type == PopupTypeDoubleTap)
    {
        key = @"DoubleTap";
    }
    else if (type == PopupTypeDontTap)
    {
        key = @"DontTap";
    }
    
    return [UIImage imageNamed:[self.imagesDict objectForKey:key]];
}

- (UIImage *)emptyImageForType:(PopupType)type
{
    NSString *key = nil;
    
    if (type == PopupTypeSingleTap)
    {
        key = @"SingleTapEmpty";
    }
    else if (type == PopupTypeDoubleTap)
    {
        key = @"DoubleTapEmpty";
    }
    
    return [UIImage imageNamed:[self.imagesDict objectForKey:key]];

}

@end
