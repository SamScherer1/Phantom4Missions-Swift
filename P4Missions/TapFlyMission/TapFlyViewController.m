//
//  TapFlyViewController.m
//  P4Missions
//
//  Created by DJI on 15/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "TapFlyViewController.h"
#import "PointingTouchView.h"
#import "DemoUtility.h"
#import "StatusViewController.h"

@interface TapFlyViewController () <DJICameraDelegate, DJIMissionManagerDelegate>

@property (weak, nonatomic) IBOutlet UIView *fpvView;
@property (weak, nonatomic) IBOutlet PointingTouchView *touchView;
@property (weak, nonatomic) IBOutlet UIButton* startMissionBtn;
@property (weak, nonatomic) IBOutlet UIButton* stopMissionBtn;
@property (weak, nonatomic) IBOutlet UILabel* speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *horiObstacleAvoidLabel;

@property (nonatomic, assign) BOOL isHorizontalObstacleAvoidanceEnabled;
@property (nonatomic, assign) BOOL isMissionRunning;
@property (nonatomic, assign) float speed;
@property (nonatomic, strong) NSMutableString *logString;

@end

@implementation TapFlyViewController

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

}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VideoPreviewer instance] unSetView];
    [[VideoPreviewer instance] setView:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"TapFly Mission";
    
    // Do any additional setup after loading the view from its nib.
    self.logString = [NSMutableString string];
    self.speed = 5.0;
    self.isMissionRunning = NO;
    self.isHorizontalObstacleAvoidanceEnabled = NO;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScreenTouched:)];
    [self.touchView addGestureRecognizer:tapGesture];
    
    self.startMissionBtn.layer.cornerRadius = self.startMissionBtn.frame.size.width * 0.5;
    self.startMissionBtn.layer.borderColor = [UIColor blueColor].CGColor;
    self.startMissionBtn.layer.borderWidth = 1.2;
    self.startMissionBtn.layer.masksToBounds = YES;
    
    self.stopMissionBtn.layer.cornerRadius = self.stopMissionBtn.frame.size.width * 0.5;
    self.stopMissionBtn.layer.borderColor = [UIColor blueColor].CGColor;
    self.stopMissionBtn.layer.borderWidth = 1.2;
    self.stopMissionBtn.layer.masksToBounds = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.speedLabel setTextColor:[UIColor blackColor]];
        [self.horiObstacleAvoidLabel setTextColor:[UIColor blackColor]];
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        [self.speedLabel setTextColor:[UIColor whiteColor]];
        [self.horiObstacleAvoidLabel setTextColor:[UIColor whiteColor]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIViewController Delegate Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    StatusViewController *statusVC = (StatusViewController *)segue.destinationViewController;
    [statusVC setStatusText:self.logString];
}

#pragma mark IBAction Methods

-(IBAction) onSliderValueChanged:(UISlider*)slider
{
    float speed = slider.value * 10;
    self.speed = speed;
    self.speedLabel.text = [NSString stringWithFormat:@"%0.1fm/s", speed];
    if (self.isMissionRunning) {
        [DJITapFlyMission setAutoFlightSpeed:self.speed withCompletion:^(NSError * _Nullable error) {
            NSLog(@"Set TapFly Auto Flight Speed:%0.1f Error:%@", speed, error.localizedDescription);
        }];
    }
}

-(IBAction) onSwitchValueChanged:(UISwitch*)sender
{
    self.isHorizontalObstacleAvoidanceEnabled = sender.isOn;
}

-(IBAction) onStartMissionButtonAction:(UIButton*)sender
{
    weakSelf(target);
    [[DJIMissionManager sharedInstance] startMissionExecutionWithCompletion:^(NSError * _Nullable error) {
            ShowResult(@"Start Mission:%@", error.localizedDescription);
            if (!error) {
                weakReturn(target);
                [target shouldShowStartMissionButton:NO];
            }else
            {
                ShowResult(@"StartMission Failed: %@", error.description);
            }
    }];
}

-(IBAction) onStopMissionButtonAction:(UIButton*)sender
{
    
    weakSelf(target);
    [[DJIMissionManager sharedInstance] stopMissionExecutionWithCompletion:^(NSError * _Nullable error) {
        ShowResult(@"Stop Mission:%@", error.localizedDescription);
        if (!error) {
            weakReturn(target);
            [target hideMissionControlButton];
            target.isMissionRunning = NO;
        }
    }];
}

#pragma mark Custom Methods

-(void) onScreenTouched:(UIGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.touchView];
    [self.touchView updatePoint:point andColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
    
    point = [DemoUtility pointToStreamSpace:point withView:self.touchView];
    [self startTapFlyMissionWithPoint:point];
}

-(void) startTapFlyMissionWithPoint:(CGPoint)point
{
    DJITapFlyMission* tapFlyMission = [[DJITapFlyMission alloc] init];
    tapFlyMission.imageLocationToCalculateDirection = point;
    tapFlyMission.autoFlightSpeed = self.speed;
    tapFlyMission.isHorizontalObstacleAvoidanceEnabled = self.isHorizontalObstacleAvoidanceEnabled;
    weakSelf(target);
    [[DJIMissionManager sharedInstance] prepareMission:tapFlyMission withProgress:nil withCompletion:^(NSError * _Nullable error) {
        if (error) {
            weakReturn(target);
            [target.touchView updatePoint:INVALID_POINT];
            ShowResult(@"Prepare Mission Error:%@", error.localizedDescription);
        }
        else
        {
            [target shouldShowStartMissionButton:YES];
        }
    }];
}

//Should Show StartMissionButton and hide StopMissionButton
- (void) shouldShowStartMissionButton:(BOOL)show
{
    if (show) {
        self.startMissionBtn.hidden = NO;
        self.stopMissionBtn.hidden = YES;
    }else
    {
        self.startMissionBtn.hidden = YES;
        self.stopMissionBtn.hidden = NO;
    }
}

-(void) hideMissionControlButton
{
    [self.startMissionBtn setHidden:YES];
    [self.stopMissionBtn setHidden:YES];
}

#pragma mark - DJICameraDelegate

-(void) camera:(DJICamera*)camera didReceiveVideoData:(uint8_t*)videoBuffer length:(size_t)length
{
    uint8_t* pBuffer = (uint8_t*)malloc(length);
    memcpy(pBuffer, videoBuffer, length);
    [[VideoPreviewer instance] push:pBuffer length:(int)length];
}

#pragma mark - DJIMissionManagerDelegate

- (void)missionManager:(DJIMissionManager *_Nonnull)manager didFinishMissionExecution:(NSError *_Nullable)error
{
    ShowResult(@"Mission Finished:%@", error.localizedDescription);
    [self.touchView updatePoint:INVALID_POINT];
    [self hideMissionControlButton];
    self.isMissionRunning = NO;
}

- (void)missionManager:(DJIMissionManager *_Nonnull)manager missionProgressStatus:(DJIMissionProgressStatus *_Nonnull)missionProgress
{
    if ([missionProgress isKindOfClass:[DJITapFlyMissionStatus class]]) {
        self.isMissionRunning = YES;
        DJITapFlyMissionStatus* status = (DJITapFlyMissionStatus*)missionProgress;
        CGPoint point = status.imageLocation;
        point.x = point.x * self.fpvView.frame.size.width;
        point.y = point.y * self.fpvView.frame.size.height;
        if (CGPointEqualToPoint(point, CGPointZero)) {
            point = INVALID_POINT;
        }
        if (status.executionState == DJITapFlyMissionExecutionStateExecuting) {
            [self.touchView updatePoint:point andColor:[[UIColor greenColor] colorWithAlphaComponent:0.5]];
            [self shouldShowStartMissionButton:NO];
        }
        else if (status.executionState == DJITapFlyMissionExecutionStateCannotExecute)
        {
            [self.touchView updatePoint:point andColor:[[UIColor redColor] colorWithAlphaComponent:0.5]];
            [self shouldShowStartMissionButton:NO];
        }
        
        NSLog(@"Direction:{%f, %f, %f} ExecState:%d", status.direction.x, status.direction.y, status.direction.z, (int)status.executionState);
        
        [self.logString appendFormat:@"Execution State:%@\n", [DemoUtility stringFromPointingExecutionState:status.executionState]];
        [self.logString appendFormat:@"ByPass Direction:%@\n", [DemoUtility stringFromByPassDirection:status.bypassDirection]];
        [self.logString appendFormat:@"Direction:{%f, %f, %f}\n", status.direction.x, status.direction.y, status.direction.z];
        [self.logString appendFormat:@"View Point:{%f, %f}\n", point.x, point.y];
        [self.logString appendFormat:@"Error:%@", status.error.localizedDescription];
    }
}

@end
