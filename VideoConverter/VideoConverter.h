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
 - convert function should use NSRunLoop, etc.
 - fallback tasks (for different encoding options on error)
 
 */

@interface VideoConverter : ACConverter {
    NSTask * converterTask;
    NSPipe * errorPipe;
    NSPipe * readPipe;
    NSPipe * writePipe;
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)msg;

@end
