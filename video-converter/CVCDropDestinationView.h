//
//  CVCDropDestinationView.h
//  video-converter
//
//  Created by Carlos Ramos on 10/04/14.
//  Copyright (c) 2014 Carlos Ramos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const FileURLDroppedNotification;

@interface CVCDropDestinationView : NSView  <NSDraggingDestination>

@end
