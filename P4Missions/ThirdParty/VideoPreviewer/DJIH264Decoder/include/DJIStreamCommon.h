//
//  DJIStreamCommon.h
//  DJIWidget
//
//  Created by ai.chuyue on 15/3/5.
//  Copyright (c) 2015年 Jerome.zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define H264_FRAME_INVALIED_UUID (0)

typedef enum : NSUInteger {
    VPFrameTypeYUV420Planer = 0,
    VPFrameTypeYUV420SemiPlaner = 1,
    VPFrameTypeRGBA = 2,
} VPFrameType;

typedef struct{
    uint16_t width;
    uint16_t height;
    
    uint16_t fps;
    uint16_t reserved;
    
    uint16_t frame_index;
    uint16_t max_frame_index_plus_one;
    
    union{
        struct{
            int has_sps :1; //含有sps信息
            int has_pps :1; //含有pps信息
            int has_idr :1; //含有idr帧
        } frame_flag;
        uint32_t value;
    };
    
} VideoFrameH264BasicInfo;

typedef struct{
    uint32_t sampleRate;
    uint8_t channelCount;
    uint16_t sampleCount;
    uint8_t reserved;
} AudioFrameAACBasicInfo;

#ifndef YUV_FRAME_
#define YUV_FRAME_

typedef struct
{
    //RGB情况下，这里存储rgb -> luma
    //yuv_planer 情况下，y->luma, u->chromab, v->chromar
    //yuv_semiPlaner 情况下， y->luma, crcb->chromab
    uint8_t *luma;
    uint8_t *chromaB;
    uint8_t *chromaR;
    
    uint8_t frameType; //VPFrameType
    
    int width, height;
    
    //slice 数据，如果为0则表示默认内存紧密存放
    int lumaSlice, chromaBSlice, chromaRSlice;
    
    pthread_rwlock_t mutex;
    void* cv_pixelbuffer_fastupload; //暂留，似乎目前只支持y-uv半平面
    

    uint32_t frame_uuid; //frame id from decoder
    VideoFrameH264BasicInfo frame_info;
} VideoFrameYUV;
#endif

typedef enum : NSUInteger {
    TYPE_TAG_VideoFrameH264Raw = 0,
    TYPE_TAG_AudioFrameAACRaw = 1,
    TYPE_TAG_VideoFrameJPEG = 2,
} TYPE_TAG_VPFrame;

#pragma pack (1)
typedef struct{
    uint32_t type_tag:8;//TYPE_TAG_VideoFrameH264Raw
    uint32_t frame_size:24;
    uint32_t frame_uuid;
    uint64_t time_tag; //videoPool 内部相对时间
    VideoFrameH264BasicInfo frame_info;
    
    uint8_t frame_data[0]; //followd by frame data;
}VideoFrameH264Raw;

typedef struct{
    uint32_t type_tag:8;//TYPE_TAG_AudioFrameAACRaw
    uint32_t frame_size:24;
    uint64_t time_tag;
    AudioFrameAACBasicInfo frame_info;
    uint8_t frame_data[0];
}AudioFrameAACRaw;
#pragma pack()

typedef struct {
    CGSize frameSize; //暂留未用
    int frameRate;
    int encoderType;
} DJIVideoStreamBasicInfo;

typedef enum{
    DJIVideoStreamProcessorType_Unknown = 0,
    DJIVideoStreamProcessorType_Decoder, //decoder same as passthrough
    DJIVideoStreamProcessorType_Passthrough, //passthrough data
    DJIVideoStreamProcessorType_Consume, //consume data
    DJIVideoStreamProcessorType_Modify, //modify data
} DJIVideoStreamProcessorType;

//264编码器类型枚举
typedef NS_ENUM(NSUInteger, H264EncoderType){
    H264EncoderType_unknown = 0,
    H264EncoderType_DM368_inspire = 1, //inspire上的DM368编码
    H264EncoderType_DM368_longan = 2, //手持云台与inspire使用同样方案
    H264EncoderType_A9_phantom3c = 4, //phantom3c上的A9相机
    H264EncoderType_A9_phantom3s = 4, //phantom3s码流
    H264EncoderType_DM365_phamtom3x = 5, //phantom3x
    H264EncoderType_1860_phantom4x = 6, //phantom4x
    H264EncoderType_LightBridge2 = 7, //lb2 dm368
    H264EncoderType_A9_P3_W = 8, //p3w wifi
    H264EncoderType_A9_OSMO_NO_368 = 9, //去368方案的osmo+A9+X3相机
};

/**
 *  stream processor to decode/save stream
 */
@protocol VideoStreamProcessor <NSObject>
@required
/**
 * 启用
 */
-(BOOL) streamProcessorEnabled;

-(DJIVideoStreamProcessorType) streamProcessorType;
/**
 *  @return 处理成功/失败
 */
-(BOOL) streamProcessorHandleFrame:(uint8_t*)data size:(int)size;
-(BOOL) streamProcessorHandleFrameRaw:(VideoFrameH264Raw*)frame;
@optional
/**
 *  流基本信息发生了变化，解码器... etc需要在内部重新配置
 */
-(void) streamProcessorInfoChanged:(DJIVideoStreamBasicInfo*)info;
-(void) streamProcessorPause;
-(void) streamProcessorReset;
@end

/**
 *  frame processor to display video frame
 */
@protocol VideoFrameProcessor <NSObject>
@required
/**
 * 启用
 */
-(BOOL) videoProcessorEnabled;
-(void) videoProcessFrame:(VideoFrameYUV*)frame;
-(void) videoProcessFailedFrame;
@end