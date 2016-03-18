//
//  StatusViewController.m
//  P4Missions
//
//  Created by DJI on 16/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "StatusViewController.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Mission Status";
    [self.statusTextView setText:self.statusText];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
