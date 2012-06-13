//
//  VideoConverter.m
//  VideoConverter
//
//  Created by Alex Nichol on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideoConverter.h"

@implementation VideoConverter

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)msg {
    NSDictionary * info = [NSDictionary dictionaryWithObject:msg
                                                      forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"VideoConverter" code:code userInfo:info];
}

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    NSArray * supportedSource = [NSArray arrayWithObjects:@"mp4", @"mov", @"flv", @"avi", @"mkv", nil];
    NSArray * supportedDestination = [NSArray arrayWithObjects:@"mp4", @"mov", @"flv", @"avi", @"mkv", nil];
    if ([supportedSource containsObject:oldExt]) {
        if ([supportedDestination containsObject:newExt]) {
            return YES;
        }
    }
    return NO;
}

- (void)convertSynchronously:(ACConverterCallback)callback {
    NSBundle * currentBundle = [NSBundle bundleWithIdentifier:@"com.aqnichol.VideoConverter"];
    NSString * path = [[currentBundle resourcePath] stringByAppendingPathComponent:@"ffmpeg"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        callback(ACConverterCallbackTypeError, 0, [[self class] errorWithCode:1 message:@"No ffmpeg executable"]);
        return;
    }
    
    errorPipe = [NSPipe pipe];
    readPipe = [NSPipe pipe];
    writePipe = [NSPipe pipe];
    
    converterTask = [[NSTask alloc] init];
    [converterTask setLaunchPath:path];
    [converterTask setArguments:[NSArray arrayWithObjects:@"-f", sourceExtension, @"-i", self.file,
                                 @"-acodec", @"copy", @"-vcodec", @"libx264",
                                 @"-b:v", @"390k", @"-b:a", @"44100",
                                 @"-f", destExtension, tempFile, nil]];
    [converterTask setStandardError:errorPipe];
    [converterTask setStandardOutput:readPipe];
    [converterTask setStandardInput:writePipe];
    [converterTask launch];
}

@end
