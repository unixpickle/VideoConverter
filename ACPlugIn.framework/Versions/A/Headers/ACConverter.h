//
//  ACConverter.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACConverter;

@protocol ACConverterDelegate <NSObject>

- (void)converter:(ACConverter *)converter failedWithError:(NSError *)error;
- (void)converterFinished:(ACConverter *)converter;
- (void)converter:(ACConverter *)converter progressUpdate:(float)progress;

@end

typedef enum {
    ACConverterCallbackTypeError,
    ACConverterCallbackTypeDone,
    ACConverterCallbackTypeProgress
} ACConverterCallbackType;

typedef void (^ACConverterCallback)(ACConverterCallbackType type, double progress, NSError * error);

@interface ACConverter : NSObject {
    NSString * file;
    NSString * sourceExtension;
    NSString * destExtension;
    NSString * tempFile;
    __weak id<ACConverterDelegate> delegate;
    NSThread * backgroundThread;
    dispatch_queue_t mainQueue;
    
    NSDate * startDate;
    float _progress;
}

@property (readonly) NSString * file;
@property (readonly) NSString * sourceExtension;
@property (readonly) NSString * destExtension;
@property (readonly) NSString * tempFile;
@property (nonatomic, weak) id<ACConverterDelegate> delegate;

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt;

- (id)initWithFile:(NSString *)aFile source:(NSString *)oldExt dest:(NSString *)newExt;
- (void)beginConverting;
- (void)cancelConverting;
- (BOOL)placeTempFile:(NSError **)error;

- (void)convertSynchronously:(ACConverterCallback)callback;
- (NSString *)conversionTitle;
- (NSString *)conversionSubtitle;

@end
