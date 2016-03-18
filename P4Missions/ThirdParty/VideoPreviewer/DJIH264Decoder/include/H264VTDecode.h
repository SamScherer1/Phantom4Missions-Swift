//
//  H264VTDecode.h
//  H264DecodeTest
//
//  Created by ai.chuyue on 14-10-20.
//  Copyright (c) 2014年 ai.chuyue. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <Foundation/Foundation.h>
#import "DJIStreamCommon.h"

//interface for 264 decoder
@protocol H264DecoderOutput <NSObject>
@optional
//异步解码完成
-(void) decompressedFrame:(CVImageBufferRef)image frameInfo:(VideoFrameH264Raw*)frame;
//出现异常情况时，调用此方法来告知硬件解码器不可用
-(void) hardwareDecoderUnavailable;
@end

#define PPS_SPS_MAX_SIZS (256)
#define NAL_MAX_SIZE (1*1024*1024)
#define AU_MAX_SIZE (2*1024*1024)

@interface H264VTDecode : NSObject <VideoStreamProcessor>{
    //decoder context
    VTDecompressionSessionRef _sessionRef;
    CMVideoFormatDescriptionRef _formatDesc;
    
    //pps and sps info
    uint8_t sps_buffer[PPS_SPS_MAX_SIZS];
    uint8_t pps_buffer[PPS_SPS_MAX_SIZS];
    int pps_size;
    int sps_size;
    NSInteger _fps;
    
    //buffer for nal unit
    void* nalu_buf;
    
    //buffer for complete access unit(1frame)
    void* au_buf;
    int au_size;
    int au_nal_count;
    
    //解码帧计数
    int _income_frame_count;
    //解码器重新创建次数
    int _decoder_create_count;
}

//CVImageBuffer output delegate
@property (nonatomic, weak) id<H264DecoderOutput> delegate;
//启用标志
@property (nonatomic, assign) BOOL enabled;
//编码器模式，用于选择i帧
@property (assign, nonatomic) NSInteger encoderType;
//硬件解码器不可用
@property (nonatomic, assign) BOOL hardware_unavailable;

/***
 decode function
 in: a complete h264 frame from ffmpeg av_parser_parse2
 out: YES for decode success
 ***/
//-(BOOL) decodeCompleteFrame:(uint8_t*)data Size:(int)size;

/***
 reset decode context, 只能在解码线程相同的线程中使用
 ***/
-(void) resetInDecodeThread;

/**
 * 在之后的解码过程中释放，可用于不同线程
 **/
-(void) resetLater;

/***
 convert imagebuffer to uiimage for test
 in: CVImagePixelBuffer
 ***/
-(UIImage *) convertFromCVImageBuffer:(CVImageBufferRef)imageBuffer savePath:(NSString*)path;

/**
 *  迫使解码器输出全部帧
 */
-(void) dequeueAllFrames;
@end
