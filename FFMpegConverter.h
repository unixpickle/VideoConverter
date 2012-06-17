//
//  FFMpegConverter.h
//  VideoConverter
//
//  Created by Alex Nichol on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <ACPlugIn/ACConverter.h>

@interface FFMpegConverter : ACConverter {
    NSTask * converterTask;
    NSString * launchPath;
    NSString * tempSource;
    __unsafe_unretained ACConverterCallback callback;
    NSTimeInterval totalDuration;
    NSTimeInterval completed;
    BOOL hasDuration;
}

+ (NSString *)bundleName;
+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)msg;

- (void)removeTempSource;

- (void)executeConversion;
- (BOOL)executeEncoderWithArguments:(NSArray *)arguments;
- (BOOL)encoderTask;

- (BOOL)processOutputLine:(NSString *)line;
- (NSTimeInterval)extractDurationFromLine:(NSString *)output;
- (NSTimeInterval)extractTimestampFromLine:(NSString *)output;
- (NSTimeInterval)processTimeString:(NSString *)timeString;

@end
