//
//  GamePanelViewController.m
//  WhackADrink
//
//  Created by Alec Bettinson on 11/11/2013.
//  Copyright (c) 2013 Tapbox LTD. All rights reserved.
//

#import "GamePanelViewController.h"
#import "PopupView.h"

@interface GamePanelViewController () <PopupViewDelegate>

@property (nonatomic, strong) NSArray *popupViews;

@property (nonatomic, strong) NSTimer *popupTimer;
@property (nonatomic, assign) NSInteger multiplyer;
@property (nonatomic, assign) CGFloat popupTimerInteval;
@property (nonatomic, assign) NSInteger iteration;

@end

@implementation GamePanelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    [super loadView];
    
    NSMutableArray *popupViews = [NSMutableArray array];
    
    CGFloat xPos = 0.f;
    CGFloat yPos = 0.f;
    
    for (int i=0; i < kNumberOfHoles; i++)
    {
        PopupView *view = [PopupView popupView];
        view.frame = CGRectMake(xPos, yPos, view.frame.size.width, view.frame.size.height);
        view.delegate = self;
        [popupViews addObject:view];
        [self.view addSubview:view];
        
        xPos += view.frame.size.width + kPopupSpacing;
        
        if ((i + 1) % (kHolesPerLine) == 0)
        {
            xPos = 0;
            yPos += view.frame.size.height + kPopupSpacing;
        }
    }
    
    self.popupViews = [NSArray arrayWithArray:popupViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Game Management

- (void)startGame
{
    self.multiplyer = 1;
    self.popupTimerInteval = kBasePopupInterval;
    self.iteration = 0;
    
    [self showPopup];
    [self startPopupTimer];
}

- (void)stopGame
{
    [self cancelPopupTimer];
    
    for (PopupView *popupView in self.popupViews)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:popupView selector:@selector(popUp) object:nil];
        popupView.selectable = NO;
        [popupView popDown];
    }
}

- (void)startPopupTimer
{
    [self cancelPopupTimer];
    self.popupTimer = [NSTimer scheduledTimerWithTimeInterval:self.popupTimerInteval target:self selector:@selector(showPopup) userInfo:nil repeats:YES];
}

- (void)cancelPopupTimer
{
    if (self.popupTimer)
    {
        [self.popupTimer invalidate];
        self.popupTimer = nil;
    }
}

#pragma mark - Popup Display

- (void)showPopup
{
    self.iteration++;
    
    // Moved to background thread to stop while loop blocking the main thread
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSInteger dontTapRand = arc4random() % (kNumberOfHoles + 1);
        NSInteger tapRand = arc4random() % (kNumberOfHoles + 1);
        
        NSInteger randPopupIndex = arc4random() % (self.popupViews.count);
        
        PopupView *view = [self.popupViews objectAtIndex:randPopupIndex];
        
        while (!view.canBeShown)
        {
            randPopupIndex = arc4random() %  (self.popupViews.count);
            view = [self.popupViews objectAtIndex:randPopupIndex];
            //Added to stop spamming CPU usage
            if (!view.canBeShown) {
                [NSThread sleepForTimeInterval:0.01];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (dontTapRand <= kDontTapProbability)
            {
                view.type = PopupTypeDontTap;
            }
            else if (tapRand <= kDoubleTapProbability)
            {
                view.type = PopupTypeDoubleTap;
            }
            else
            {
                view.type = PopupTypeSingleTap;
            }
            
            [view popUp];
        });
    });
    
    if (self.iteration % (self.useShorterThreshold ? kDifficultyIterationThresholdTimed60 : kDifficultyIterationThreshold) == 0 && self.popupTimerInteval > kMinimumPopupInterval) {
        self.popupTimerInteval -= kPopupTimeReductionConstant;
        self.multiplyer++;
        
        [self startPopupTimer];
    }
}

- (void)showPopupWithType:(NSInteger)popupType atIndex:(NSInteger)index
{
    self.multiplyer = 1;
    
    PopupView *view = [self.popupViews objectAtIndex:index];
    view.type = popupType;
    [view holdUp];
}



#pragma mark - PopupDelegate

- (void)popupViewActivated:(PopupView *)view
{
    NSInteger baseScore = 0;
    
    if (view.type == PopupTypeDontTap)
    {
        baseScore = kBaseDontTapScore;
    }
    else if (view.type == PopupTypeDoubleTap)
    {
        baseScore = kBaseDoubleTapScore;
    }
    else if (view.type == PopupTypeSingleTap)
    {
        baseScore = kBaseSingleTapScore;
    }
        
    [self.delegate gamePanel:self updatedScore:self.multiplyer * baseScore];
}


@end
