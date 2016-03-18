//
//  DemoUtility.m
//  P4Missions
//
//  Created by DJI on 16/3/16.
//  Copyright © 2016 DJI. All rights reserved.
//

#import "DemoUtility.h"

void ShowResult(NSString *format, ...)
{
    va_list argumentList;
    va_start(argumentList, format);
    
    NSString* message = [[NSString alloc] initWithFormat:format arguments:argumentList];
    va_end(argumentList);
    NSString * newMessage = [message hasSuffix:@":(null)"] ? [message stringByReplacingOccurrencesOfString:@":(null)" withString:@" successful!"] : message;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:newMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    });
}

@implementation DemoUtility

+ (DJICamera *) fetchCamera {
    
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).camera;
    }
    return nil;
}

+ (DJIGimbal *)fetchGimbal
{
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).gimbal;
    }
    return nil;
}

+ (DJIFlightController *) fetchFlightController
{
    if (![DJISDKManager product]) {
        return nil;
    }
    if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
        return ((DJIAircraft*)[DJISDKManager product]).flightController;
    }
    return nil;
}

+ (CGPoint) pointToStreamSpace:(CGPoint)point withView:(UIView *)view
{
    VideoPreviewer* previewer = [VideoPreviewer instance];
    CGRect videoFrame = [previewer frame];
    CGPoint videoPoint = [previewer convertPoint:point toVideoViewFromView:view];
    CGPoint normalized = CGPointMake(videoPoint.x/videoFrame.size.width, videoPoint.y/videoFrame.size.height);
    return normalized;
}

+ (CGPoint) pointFromStreamSpace:(CGPoint)point withView:(UIView *)view{
    VideoPreviewer* previewer = [VideoPreviewer instance];
    CGRect videoFrame = [previewer frame];
    CGPoint videoPoint = CGPointMake(point.x*videoFrame.size.width, point.y*videoFrame.size.height);
    return [previewer convertPoint:videoPoint fromVideoViewToView:view];
}

+ (CGSize) sizeToStreamSpace:(CGSize)size{
    VideoPreviewer* previewer = [VideoPreviewer instance];
    CGRect videoFrame = [previewer frame];
    return CGSizeMake(size.width/videoFrame.size.width, size.height/videoFrame.size.height);
}

+ (CGSize) sizeFromStreamSpace:(CGSize)size{
    VideoPreviewer* previewer = [VideoPreviewer instance];
    CGRect videoFrame = [previewer frame];
    return CGSizeMake(size.width*videoFrame.size.width, size.height*videoFrame.size.height);
}

+ (NSString*) stringFromPointingExecutionState:(DJITapFlyMissionExecutionState)state
{
    switch (state) {
        case DJITapFlyMissionExecutionStateCannotExecute: return @"Can Not Fly";
        case DJITapFlyMissionExecutionStateExecuting: return @"Normal Flying";
        case DJITapFlyMissionExecutionStateUnknown: return @"Unknown";
    }
}

+ (NSString*) stringFromTrackingExecutionState:(DJIActiveTrackMissionExecutionState)state
{
    switch (state) {
        case DJIActiveTrackMissionExecutionStateTracking: return @"Normal Tracking";
        case DJIActiveTrackMissionExecutionStateTrackingWithLowConfidence: return @"Tracking Uncertain Target";
        case DJIActiveTrackMissionExecutionStateWaitingForConfirmation: return @"Need Confirm";
        case DJIActiveTrackMissionExecutionStateTargetLost: return @"Target Lost";
        case DJIActiveTrackMissionExecutionStateCannotContinue: return @"Waiting";
        case DJIActiveTrackMissionExecutionStateUnknown: return @"Unknown";
    }
}

+ (NSString*) stringFromByPassDirection:(DJIBypassDirection)direction
{
    switch (direction) {
        case DJIBypassDirectionNone: return @"None";
        case DJIBypassDirectionOver: return @"From Top";
        case DJIBypassDirectionLeft: return @"From Left";
        case DJIBypassDirectionRight: return @"From Right";
        case DJIBypassDirectionUnknown: return @"Unknown";
    }
    return nil;
}

@end
