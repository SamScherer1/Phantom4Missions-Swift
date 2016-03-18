//
//  SoftwareDecodeProcessor.h
//  DJIWidget
//
//  Created by ai.chuyue on 15/3/5.
//  Copyright (c) 2015年 Jerome.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"
#import "VideoFrameExtractor.h"

@interface SoftwareDecodeProcessor : NSObject <VideoStreamProcessor>
@property (nonatomic, weak) id<VideoFrameProcessor> frameProcessor;
@property (nonatomic, assign) BOOL enabled;

-(id) initWithExtractor:(VideoFrameExtractor*)extractor;
@end
