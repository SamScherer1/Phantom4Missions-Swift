//
//  ActiveTrackViewController.m
//  P4Missions
//
//  Created by DJI on 15/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "ActiveTrackViewController.h"
#import "TrackingRenderView.h"
#import "DemoUtility.h"
#import "StatusViewController.h"

@interface ActiveTrackViewController () <DJICameraDelegate, DJIMissionManagerDelegate, TrackingRenderViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvView;
@property (weak, nonatomic) IBOutlet TrackingRenderView *renderView;
@property (weak, nonatomic) IBOutlet UIButton* stopButton;
@property (weak, nonatomic) IBOutlet UILabel *retreatEnabledLabel;

@property(nonatomic, assign) CGRect currentTrackingRect;
@property (nonatomic, strong) NSMutableString *logString;

@property(nonatomic, assign) BOOL isNeedConfirm;
@property(nonatomic, assign) BOOL isTrackingMissionRunning;
@property(nonatomic, assign) BOOL isRetreatEnabled;

@end

@implementation ActiveTrackViewController

#pragma mark - Inherited Methods

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[VideoPreviewer instance] setDecoderWithProduct:[DJISDKManager product] andDecoderType:VideoPreviewerDecoderTypeSoftwareDecoder];
    [[VideoPreviewer instance] setView:self.fpvView];
    
    [DJIMissionManager sharedInstance].delegate = self;
    
    DJICamera* camera = [DemoUtility fetchCamera];
    if (camera) {
        camera.delegate = self;
    }
    
    [[VideoPreviewer instance] start];
    
    [DJIActiveTrackMission setRecommendedConfigurationWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            ShowResult(@"Set Recommended Camera Settings:%@", error.localizedDescription);            
        }
    }];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VideoPreviewer instance] unSetView];
    [[VideoPreviewer instance] setView:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ActiveTrack Mission";

    self.renderView.delegate = self;
    
    self.isRetreatEnabled = NO;
    self.logString = [NSMutableString string];
    self.stopButton.layer.cornerRadius = self.stopButton.frame.size.width * 0.5;
    self.stopButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.stopButton.layer.borderWidth = 1.0;
    self.stopButton.layer.masksToBounds = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.retreatEnabledLabel setTextColor:[UIColor blackColor]];
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.retreatEnabledLabel setTextColor:[UIColor whiteColor]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UIViewController Delegate Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    StatusViewController *statusVC = (StatusViewController *)segue.destinationViewController;
    [statusVC setStatusText:self.logString];
}

#pragma mark TrackingRenderView Delegate Methods

-(void) renderViewDidTouchAtPoint:(CGPoint)point
{
    if (self.isTrackingMissionRunning && !self.isNeedConfirm) {
        return;
    }
    
    if (self.isNeedConfirm) {
        NSLog(@"TrackingRect:{%0.1f, %0.1f, %0.1f, %0.1f} Point:{%0.1f, %0.1f}", self.currentTrackingRect.origin.x, self.currentTrackingRect.origin.y, self.currentTrackingRect.size.width, self.currentTrackingRect.size.height, point.x, point.y);
        CGRect largeRect = CGRectInset(self.currentTrackingRect, -10, -10);
        if (CGRectContainsPoint(largeRect, point)) {
            [DJIActiveTrackMission acceptConfirmationWithCompletion:^(NSError * _Nullable error) {
                ShowResult(@"Confirm Tracking:%@", error.localizedDescription);
            }];
        }
        else
        {
            [DJIActiveTrackMission rejectConfirmationWithCompletion:^(NSError * _Nullable error) {
                ShowResult(@"Cancel Tracking:%@", error.localizedDescription);
            }];
        }
    }
    else
    {
        weakSelf(target);
        point = [DemoUtility pointToStreamSpace:point withView:self.renderView];
        DJIActiveTrackMission* mission = [[DJIActiveTrackMission alloc] init];
        mission.rect = CGRectMake(point.x, point.y, 0, 0);
        [[DJIMissionManager sharedInstance] prepareMission:mission withProgress:nil withCompletion:^(NSError * _Nullable error) {
            if (error) {
                ShowResult(@"Prepare Mission Error:%@", error.localizedDescription);
                if (error) {
                    weakReturn(target);
                    target.renderView.isDottedLine = NO;
                    [target.renderView updateRect:CGRectNull fillColor:nil];
                }
            }
            else
            {
                [[DJIMissionManager sharedInstance] startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
                    ShowResult(@"Start Mission:%@", error.localizedDescription);
                    if (error) {
                        weakReturn(target);
                        target.renderView.isDottedLine = NO;
                        [target.renderView updateRect:CGRectNull fillColor:nil];
                    }
                }];
            }
        }];
    }
}

-(void) renderViewDidMoveToPoint:(CGPoint)endPoint fromPoint:(CGPoint)startPoint isFinished:(BOOL)finished
{
    if (self.isTrackingMissionRunning) {
        return;
    }
    
    self.renderView.isDottedLine = YES;
    self.renderView.text = nil;
    CGRect rect = [DemoUtility rectWithPoint:startPoint andPoint:endPoint];
    [self.renderView updateRect:rect fillColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
    if (finished) {
        CGRect rect = [DemoUtility rectWithPoint:startPoint andPoint:endPoint];
        [self startMissionWithRect:rect];
    }
}

#pragma mark IBAction Methods

- (IBAction) onStopButtonClicked:(id)sender
{
    weakSelf(target);
    [[DJIMissionManager sharedInstance] stopMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        ShowResult(@"Stop Mission:%@", error.localizedDescription);
        if (!error) {
            weakReturn(target);
            target.stopButton.hidden = YES;
            [target.renderView updateRect:CGRectNull fillColor:nil];
            target.isTrackingMissionRunning = NO;
        }
    }];
}

- (IBAction) onSwitchValueChanged:(UISwitch*)sender
{
    self.isRetreatEnabled = sender.isOn;
}

#pragma mark Custom Methods
-(void) startMissionWithRect:(CGRect)rect
{
    CGRect normalizedRect = [DemoUtility rectToStreamSpace:rect withView:self.renderView];
    weakSelf(target);
    NSLog(@"Start Mission:{%f, %f, %f, %f}", normalizedRect.origin.x, normalizedRect.origin.y, normalizedRect.size.width, normalizedRect.size.height);
    DJIActiveTrackMission* trackMission = [[DJIActiveTrackMission alloc] init];
    trackMission.rect = normalizedRect;
    trackMission.isRetreatEnabled = self.isRetreatEnabled;
    [[DJIMissionManager sharedInstance] prepareMission:trackMission withProgress:nil withCompletion:^(NSError * _Nullable error) {
        if (error) {
            weakReturn(target);
            target.renderView.isDottedLine = NO;
            [target.renderView updateRect:CGRectNull fillColor:nil];
            target.isTrackingMissionRunning = NO;
            ShowResult(@"Prepare Error:%@", error.localizedDescription);
        }
        else
        {
            [[DJIMissionManager sharedInstance] startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
                ShowResult(@"Start Mission:%@", error.localizedDescription);
                if (error) {
                    weakReturn(target);
                    target.renderView.isDottedLine = NO;
                    [target.renderView updateRect:CGRectNull fillColor:nil];
                    target.isTrackingMissionRunning = NO;
                }
            }];
        }
    }];
}

#pragma mark - DJICameraDelegate Method

-(void) camera:(DJICamera*)camera didReceiveVideoData:(uint8_t*)videoBuffer length:(size_t)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[VideoPreviewer instance] push:pBuffer length:(int)length];
}

#pragma mark - DJIMissionManagerDelegate Methods

- (void)missionManager:(DJIMissionManager *_Nonnull)manager didFinishMissionExecution:(NSError *_Nullable)error
{
    [self.renderView updateRect:CGRectNull fillColor:nil];
    self.stopButton.hidden = YES;
    self.isTrackingMissionRunning = NO;
}

- (void)missionManager:(DJIMissionManager *_Nonnull)manager missionProgressStatus:(DJIMissionProgressStatus *_Nonnull)missionProgress
{
    if ([missionProgress isKindOfClass:[DJIActiveTrackMissionStatus class]]) {
        self.isTrackingMissionRunning = YES;
        self.stopButton.hidden = NO;
        DJIActiveTrackMissionStatus* status = (DJIActiveTrackMissionStatus*)missionProgress;
        CGRect rect = [DemoUtility rectFromStreamSpace:status.trackingRect withView:self.renderView];
        self.currentTrackingRect = rect;
        if (status.executionState == DJIActiveTrackMissionExecutionStateWaitingForConfirmation) {
            NSLog(@"Mission Need Confirm...");
            self.renderView.text = @"?";
            if (!self.isNeedConfirm) {
                self.isNeedConfirm = YES;
            }
        }
        else if (status.executionState == DJIActiveTrackMissionExecutionStateTargetLost)
        {
            NSLog(@"Mission Target Lost...");
            self.renderView.isDottedLine = NO;
            self.renderView.text = nil;
            self.isNeedConfirm = NO;
            [self.renderView updateRect:CGRectNull fillColor:nil];
        }
        else if (status.executionState == DJIActiveTrackMissionExecutionStateTracking ||
                 status.executionState == DJIActiveTrackMissionExecutionStateTrackingWithLowConfidence)
        {
            self.renderView.isDottedLine = NO;
            self.renderView.text = nil;
            self.isNeedConfirm = NO;
            [self.renderView updateRect:rect fillColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
            NSLog(@"Mission Tracking...");
        }
        else if (status.executionState == DJIActiveTrackMissionExecutionStateCannotContinue)
        {
            NSLog(@"Mission Waiting...");
            self.renderView.isDottedLine = NO;
            self.renderView.text = nil;
            self.isNeedConfirm = NO;
            [self.renderView updateRect:rect fillColor:[[UIColor redColor] colorWithAlphaComponent:0.5]];
        }
        
        [self.logString appendFormat:@"Execution State:%@\n", [DemoUtility stringFromTrackingExecutionState:status.executionState]];
        [self.logString appendFormat:@"trackingRect:{%f, %f, %f, %f}\n", status.trackingRect.origin.x, status.trackingRect.origin.y, status.trackingRect.size.width, status.trackingRect.size.height];
        [self.logString appendFormat:@"Error:%@", status.error.localizedDescription];
        
    }
}

@end
