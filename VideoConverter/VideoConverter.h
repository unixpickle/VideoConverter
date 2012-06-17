//
//  VideoConverter.h
//  VideoConverter
//
//  Created by Alex Nichol on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FFMpegConverter.h"

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

@interface VideoConverter : FFMpegConverter 

- (BOOL)encodePreservingCodecs;
- (BOOL)encodeUsingH264;
- (BOOL)encodeUsingOGGVorbis;

@end
