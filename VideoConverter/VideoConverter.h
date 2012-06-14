//
//  VideoConverter.h
//  VideoConverter
//
//  Created by Alex Nichol on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <ACPlugIn/ACConverter.h>

/*
 
 TODO:
 - start the proper ffmpeg task
 - read ffmpeg data output through NSFileHandle
 - handle errors, NSTask termination, etc.
 - search output for duration
 - search output for status updates
 - send delegate nice callback info
 - fallback tasks (for different encoding options on error)
 
 */

@interface VideoConverter : ACConverter {
    NSTask * converterTask;
    NSString * launchPath;
    NSString * tempSource;
    __unsafe_unretained ACConverterCallback callback;
    NSTimeInterval totalDuration;
    NSTimeInterval completed;
    BOOL hasDuration;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)msg;

- (void)removeTempSource;

- (BOOL)encodePreservingCodecs;
- (BOOL)encodeUsingH264;
- (BOOL)encoderTask;

- (BOOL)processOutputLine:(NSString *)line;
- (NSTimeInterval)extractDurationFromLine:(NSString *)output;
- (NSTimeInterval)extractTimestampFromLine:(NSString *)output;
- (NSTimeInterval)processTimeString:(NSString *)timeString;

@end
