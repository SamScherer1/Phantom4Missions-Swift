//
//  TrackingRenderView.h
//  P4MissionsDemo
//
//  Created by DJI on 16/2/26.
//  Copyright © 2016年 DJI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrackingRenderViewDelegate <NSObject>

@optional

-(void) renderViewDidTouchAtPoint:(CGPoint)point;

-(void) renderViewDidMovePoint:(CGPoint)targetPoint fromPoint:(CGPoint)originPoint isFinished:(BOOL)finished;

@end

@interface TrackingRenderView : UIView

@property(nonatomic, weak) IBOutlet id<TrackingRenderViewDelegate> delegate;

@property(nonatomic, assign) CGRect trackingRect;

@property(nonatomic, assign) BOOL isDotLine;

@property(nonatomic, strong) NSString* text;

-(void) updateRect:(CGRect)rect fillClole:(UIColor*)fillColor;

@end
