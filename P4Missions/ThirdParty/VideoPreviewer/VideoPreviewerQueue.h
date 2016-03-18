//
//  VideoPreviewerQueue.h
//  DJIOSD
//
//  Created by Jerome.zhang on 13-11-13.
//  Copyright (c) 2013年 Jerome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

/**
 *  Thread-safe Queue
 */
@interface VideoPreviewerQueue : NSObject

/**
 *  Creates a queue object.
 *
 *  @param size the initial size
 *
 *  @return the created queue
 */
- (VideoPreviewerQueue *)initWithSize:(int)size;

/**
 *  Cleans objects in queue.
 */
- (void)clear;

/**
 *  Gets the number of objects in queue.
 *
 *  @return the number of objects in queue
 */
- (int)count;

/**
 *  Get the size of the queue.
 *
 *  @return size in queue
 */
- (int)size;

/**
 *  将数据放入队列(由队列和后续取出队列者去释放数据。 )
 *
 *  @param buf 数据指针
 *  @param len 数据长度
 *
 *  @return 当返回值为No时队列满（若队列长度为0也返回NO）
 */
- (BOOL)push:(uint8_t *)buf length:(int)len;

/**
 *  将数据取出队列
 *
 *  @param len 返回数据的长度
 *
 *  @return 当返回值为NULL时，队列为空。
 */
- (uint8_t *)pull:(int *)len;

/**
 *  是否已满
 *
 *  @return 队列是否满
 */
- (bool)isFull;

/**
 * 特殊用法，用于立即wakeup等待的某个read线程，pull方法将会返回null
 */
- (void)wakeupReader;

@end
