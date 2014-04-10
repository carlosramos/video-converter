//
//  CVCAppDelegate.h
//  video-converter
//
//  Created by Carlos Ramos on 10/04/14.
//  Copyright (c) 2014 Carlos Ramos. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface CVCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) NSNumber * currentTimeForSlider;

@property (nonatomic, readonly) NSString *currentStartTime;
@property (nonatomic, readonly) NSString *currentEndTime;

@property (nonatomic) NSNumber *videoStart;
@property (nonatomic, copy) NSNumber *videoEnd;

@end
