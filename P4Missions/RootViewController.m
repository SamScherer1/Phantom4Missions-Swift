//
//  RootViewController.m
//  P4Missions
//
//  Created by DJI on 15/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "RootViewController.h"
#import "DemoUtility.h"

@interface RootViewController ()<DJISDKManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *tapFlyMissionButton;
@property (weak, nonatomic) IBOutlet UIButton *activeTrackMissionButton;

@end

@implementation RootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Phantom 4 Missions Demo";
    [self registerApp];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Custom Methods

- (void)registerApp
{
    NSString *appKey = @"Please enter your App Key here.";
    [DJISDKManager registerApp:appKey withDelegate:self];
}

- (void)showAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark DJISDKManagerDelegate Method

-(void) sdkManagerProductDidChangeFrom:(DJIBaseProduct* _Nullable) oldProduct to:(DJIBaseProduct* _Nullable) newProduct
{
    [self.tapFlyMissionButton setEnabled:YES];
    [self.activeTrackMissionButton setEnabled:YES];
}

- (void)sdkManagerDidRegisterAppWithError:(NSError *)error
{
    if (error) {
        NSString* message = @"Register App Failed! Please enter your App Key and check the network.";
        [self.tapFlyMissionButton setEnabled:NO];
        [self.activeTrackMissionButton setEnabled:NO];
        [self showAlertViewWithTitle:@"Register App" withMessage:message];

    }else
    {
        NSLog(@"registerAppSuccess");
        [DJISDKManager startConnectionToProduct];

    }
    
}


@end
