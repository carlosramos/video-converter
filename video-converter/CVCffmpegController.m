//
//  CVCffmpegController.m
//  video-converter
//
//  Created by Carlos Ramos on 10/04/14.
//  Copyright (c) 2014 Carlos Ramos. All rights reserved.
//

#import "CVCffmpegController.h"

@implementation CVCffmpegController

- (void)callFFMPEG
{
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/local/bin/ffmpeg"];
    task.arguments = @[@"--help"];
    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;
    NSFileHandle *outputHandle = [pipe fileHandleForReading];
    [task launch];
    NSData *data = [outputHandle readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"ffmpeg: %@", string);
}

@end
