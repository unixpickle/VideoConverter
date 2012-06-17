//
//  VideoConverter.m
//  VideoConverter
//
//  Created by Alex Nichol on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoConverter.h"

@implementation VideoConverter

+ (NSString *)bundleName {
    return @"com.aqnichol.VideoConverter";
}

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    NSArray * supportedSource = [NSArray arrayWithObjects:@"mp4", @"mov", @"flv",
                                 @"avi", @"mkv", @"ogg", @"ogv", nil];
    NSArray * supportedDestination = [NSArray arrayWithObjects:@"mp4", @"mov", @"flv",
                                      @"avi", @"mkv", @"ogg", @"ogv",  nil];
    if ([supportedSource containsObject:oldExt]) {
        if ([supportedDestination containsObject:newExt]) {
            return YES;
        }
    }
    return NO;
}

- (void)executeConversion {
    BOOL encodingResult = NO;
    if ([destExtension isEqualToString:@"ogg"] || [destExtension isEqualToString:@"ogv"]) {
        encodingResult = [self encodeUsingOGGVorbis];
    } else {
        encodingResult = [self encodeUsingH264];
    }
    
    if (!encodingResult) {
        [self removeTempSource];
        if ([[NSThread currentThread] isCancelled]) return;
        
        callback(ACConverterCallbackTypeError, 0, [[self class] errorWithCode:2 message:@"No presets worked"]);
        return;
    }
    
    [self removeTempSource];
    if ([[NSThread currentThread] isCancelled]) return;
    
    NSError * placeError = nil;
    if (![self placeTempFile:&placeError]) {
        callback(ACConverterCallbackTypeError, 0, placeError);
        return;
    }
}

- (BOOL)encodePreservingCodecs {
    return [self executeEncoderWithArguments:[NSArray arrayWithObjects:@"-stats", 
                                              @"-i", tempSource,
                                              @"-acodec", @"copy", @"-vcodec", @"copy",
                                              @"-b:v", @"390k", @"-b:a", @"44100",
                                              tempFile, nil]];
}

- (BOOL)encodeUsingH264 {
    return [self executeEncoderWithArguments:[NSArray arrayWithObjects:@"-stats",
                                              @"-i", tempSource,
                                              @"-acodec", @"copy", @"-vcodec", @"libx264",
                                              @"-b:v", @"390k", /*@"-b:a", @"44100",*/
                                              tempFile, nil]];
}

- (BOOL)encodeUsingOGGVorbis {
    return [self executeEncoderWithArguments:[NSArray arrayWithObjects:@"-stats",
                                              @"-i", tempSource,
                                              @"-acodec", @"libvorbis", @"-vcodec", @"libtheora",
                                              @"-b:v", @"400k", /*@"-b:a", @"44100",*/
                                              tempFile, nil]];
}

@end
