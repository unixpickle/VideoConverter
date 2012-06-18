//
//  FFMPEGAudio.m
//  VideoConverter
//
//  Created by Alex Nichol on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FFMPEGAudio.h"

@implementation FFMPEGAudio

+ (NSString *)bundleName {
    return @"com.aqnichol.FFMPEGAudio";
}

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    NSArray * supportedSource = [NSArray arrayWithObjects:@"flac", @"wav", @"xm", @"m4a", nil];
    NSArray * supportedDestination = [NSArray arrayWithObjects:@"flac", @"wav", @"m4a", nil];
    if ([supportedSource containsObject:oldExt]) {
        if ([supportedDestination containsObject:newExt]) {
            return YES;
        }
    }
    return NO;
}

- (void)executeConversion {
    BOOL encodingResult = NO;
    if ([destExtension isEqualToString:@"m4a"]) {
        encodingResult = [self encodeWithLibFaac];
    } else {
        encodingResult = [self encodeWithNoOptions];
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

- (BOOL)encodeWithNoOptions {
    return [self executeEncoderWithArguments:[NSArray arrayWithObjects:@"-stats", 
                                              @"-i", tempSource,
                                              tempFile, nil]];
}

- (BOOL)encodeWithLibFaac {
    return [self executeEncoderWithArguments:[NSArray arrayWithObjects:@"-stats", 
                                              @"-i", tempSource,
                                              @"-acodec", @"libfaac",
                                              tempFile, nil]];
}

@end
