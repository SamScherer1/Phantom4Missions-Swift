//
//  StatusViewController.h
//  P4Missions
//
//  Created by DJI on 16/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController
@property (nonatomic, strong)IBOutlet UITextView *statusTextView;
@property (nonatomic, strong)NSString *statusText;
@end
