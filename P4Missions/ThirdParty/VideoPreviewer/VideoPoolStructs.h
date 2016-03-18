//
//  VideoPoolStructs.h
//  DJIWidget
//
//  Created by ai.chuyue on 14/12/8.
//  Copyright (c) 2014年 Jerome.zhang. All rights reserved.
//

#ifndef DJIWidget_VideoPoolStructs_h
#define DJIWidget_VideoPoolStructs_h

typedef struct _VideoCacheFrame{
    int size;
    uint32_t time_tag; //videoTimeCapsule内部相对时间
    uint8_t* data;
    
} VideoCacheFrame;



typedef struct _VideoPoolFrame{
    uint32_t file_offset;
    uint32_t frame_size;
    uint32_t time_tag; //videoPool 内部相对时间
    
    union{
        struct{
            int has_sps :1; //含有sps信息
            int has_pps :1; //含有pps信息
            int has_idr :1; //含有idr帧
        } flags;
        uint32_t value;
    };
} VideoPoolFrame;

void ReleaseVideoCacheFrameList(int count, VideoCacheFrame* list);

#endif
