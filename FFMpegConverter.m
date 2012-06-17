//
//  FFMpegConverter.m
//  VideoConverter
//
//  Created by Alex Nichol on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FFMpegConverter.h"

@implementation FFMpegConverter

+ (NSString *)bundleName {
    return nil;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)msg {
    NSDictionary * info = [NSDictionary dictionaryWithObject:msg
                                                      forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"FFMpegConverter" code:code userInfo:info];
}

- (id)initWithFile:(NSString *)aFile source:(NSString *)oldExt dest:(NSString *)newExt {
    if ((self = [super init])) {
        sourceExtension = oldExt;
        destExtension = newExt;
        file = aFile;
        
        // generate a destination temp file
        NSString * tempBase = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.aqnichol.acdaemon.temp"];
        for (int i = 1; i < 1000; i++) {
            NSString * testTemp = [tempBase stringByAppendingFormat:@".%d.%@", i, destExtension];
            if (![[NSFileManager defaultManager] fileExistsAtPath:testTemp]) {
                if (![[NSFileManager defaultManager] createFileAtPath:testTemp contents:[NSData data] attributes:nil]) {
                    return nil;
                }
                tempFile = testTemp;
                break;
            }
        }
        
        // generate a source temp file
        for (int i = 1; i < 1000; i++) {
            NSString * testTemp = [tempBase stringByAppendingFormat:@".%d.%@", i, sourceExtension];
            if (![[NSFileManager defaultManager] fileExistsAtPath:testTemp]) {
                if (![[NSFileManager defaultManager] createSymbolicLinkAtPath:testTemp
                                                          withDestinationPath:self.file
                                                                        error:nil]) {
                    return nil;
                }
                tempSource = testTemp;
                break;
            }
        }
    }
    return self;
}

- (void)removeTempSource {
    if (tempSource) {
        [[NSFileManager defaultManager] removeItemAtPath:tempSource error:nil];
        tempSource = nil;
    }
}

- (void)convertSynchronously:(ACConverterCallback)aCallback {
    callback = aCallback;
    
    NSBundle * currentBundle = [NSBundle bundleWithIdentifier:[[self class] bundleName]];
    launchPath = [[currentBundle resourcePath] stringByAppendingPathComponent:@"ffmpeg"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:launchPath]) {
        callback(ACConverterCallbackTypeError, 0, [[self class] errorWithCode:1 message:@"No ffmpeg executable"]);
        return;
    }
    
    [self executeConversion];
}

- (void)executeConversion {
    
}

- (BOOL)executeEncoderWithArguments:(NSArray *)arguments {
    NSPipe * readPipe = [NSPipe pipe];
    NSPipe * writePipe = [NSPipe pipe];
    
    converterTask = [[NSTask alloc] init];
    [converterTask setLaunchPath:launchPath];
    [converterTask setArguments:arguments];
    [converterTask setStandardError:readPipe];
    [converterTask setStandardOutput:readPipe];
    [converterTask setStandardInput:writePipe];
    return [self encoderTask];
}

- (BOOL)encoderTask {
    [converterTask launch];
    NSFileHandle * readHandle = [[converterTask standardOutput] fileHandleForReading];
    NSFileHandle * writeHandle = [[converterTask standardInput] fileHandleForWriting];
    
    hasDuration = NO;
    
    // catch any prompts that we might not catch the "good" way
    // [writeHandle writeData:[@"y\n" dataUsingEncoding:NSASCIIStringEncoding]];
    // [writeHandle writeData:[@"y\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSMutableString * outputString = [NSMutableString string];
    NSCharacterSet * newLineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n\r"];
    while ([converterTask isRunning]) {
        if ([[NSThread currentThread] isCancelled]) {
            [converterTask terminate];
            return NO;
        }
        @autoreleasepool {
            NSData * someData = [readHandle availableData];
            if ([someData length] != 0) [outputString appendString:[[NSString alloc] initWithData:someData encoding:NSUTF8StringEncoding]];
            
            if ([outputString hasSuffix:@"[y/N] "]) {
                [writeHandle writeData:[@"y\n" dataUsingEncoding:NSASCIIStringEncoding]];
                // the following two lines prevent status from working sometimes
                // [outputString deleteCharactersInRange:NSMakeRange(0, [outputString length])];
                //  continue;
            }
            
            NSRange newLineRange = [outputString rangeOfCharacterFromSet:newLineSet];
            while (newLineRange.location != NSNotFound) {
                NSString * line = [outputString substringWithRange:NSMakeRange(0, newLineRange.location)];
                [outputString deleteCharactersInRange:NSMakeRange(0, newLineRange.location + 1)];
                
                if (![self processOutputLine:line]) {
                    [converterTask terminate];
                    return NO;
                }
                
                newLineRange = [outputString rangeOfCharacterFromSet:newLineSet];
            }
        }
    }
    
    return ([converterTask terminationStatus] == 0);
}

#pragma mark - Output Extraction -

- (BOOL)processOutputLine:(NSString *)line {
    NSFileHandle * writeHandle = [[converterTask standardInput] fileHandleForWriting];
    if ([line hasSuffix:@"[y/N] "] || [line hasSuffix:@"[y/N]"]) {
        [writeHandle writeData:[@"y\n" dataUsingEncoding:NSASCIIStringEncoding]];
    } else if ([line rangeOfString:@"Duration:"].location != NSNotFound) {
        // NSLog(@"duration: %@", line);
        hasDuration = YES;
        totalDuration = [self extractDurationFromLine:line];
    } else if ([line rangeOfString:@"time="].location != NSNotFound) {
        // NSLog(@"timestamp: %@", line);
        completed = [self extractTimestampFromLine:line];
        if (hasDuration) {
            callback(ACConverterCallbackTypeProgress, completed / totalDuration, nil);
        }
    }
    return YES;
}

- (NSTimeInterval)extractDurationFromLine:(NSString *)output {
    NSRange durationRange = [output rangeOfString:@"Duration:"];
    NSInteger startIndex = durationRange.location + durationRange.length;
    NSRange endRange = [output rangeOfString:@","
                                     options:0
                                       range:NSMakeRange(startIndex, [output length] - startIndex)];
    
    // strip out actual duration string ("Duration: <str>,")
    NSString * durationString = nil;
    if (endRange.location == NSNotFound) {
        durationString = [output substringFromIndex:startIndex];
    } else {
        durationString = [output substringWithRange:NSMakeRange(startIndex, endRange.location - startIndex)];
    }
    durationString = [durationString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return [self processTimeString:durationString];
}

- (NSTimeInterval)extractTimestampFromLine:(NSString *)output {
    NSRange timeRange = [output rangeOfString:@"time="];
    NSInteger startIndex = timeRange.location + timeRange.length;
    NSRange endRange = [output rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]
                                               options:0
                                                 range:NSMakeRange(startIndex, [output length] - startIndex)];
    
    // strip out actual duration string ("time=<str>\s")
    NSString * durationString = nil;
    if (endRange.location == NSNotFound) {
        durationString = [output substringFromIndex:startIndex];
    } else {
        durationString = [output substringWithRange:NSMakeRange(startIndex, endRange.location - startIndex)];
    }
    durationString = [durationString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [self processTimeString:durationString];
    
}

- (NSTimeInterval)processTimeString:(NSString *)timeString {
    NSArray * components = [timeString componentsSeparatedByString:@":"];
    NSTimeInterval duration = 0;
    NSTimeInterval scale = 1;
    for (int i = [components count] - 1; i >= 0; i--) {
        duration += scale * [[components objectAtIndex:i] doubleValue];
        scale *= 60;
    }
    return duration;
}

- (void)dealloc {
    [self removeTempSource];
}

@end
