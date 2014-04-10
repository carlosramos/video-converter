//
//  CVCDropDestinationView.m
//  video-converter
//
//  Created by Carlos Ramos on 10/04/14.
//  Copyright (c) 2014 Carlos Ramos. All rights reserved.
//

#import "CVCDropDestinationView.h"

NSString *const FileURLDroppedNotification = @"FileURLDroppedNotification";

@implementation CVCDropDestinationView {
    BOOL highlight;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self registerForDraggedTypes:@[NSURLPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    highlight = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationGeneric;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    highlight = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    highlight = NO;
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    [[NSNotificationCenter defaultCenter] postNotificationName:FileURLDroppedNotification object:self userInfo:@{@"URL": [NSURL URLFromPasteboard:pboard]}];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor grayColor] setStroke];
    [NSBezierPath setDefaultLineWidth:5];
    [NSBezierPath strokeRect:self.bounds];
    
    if (highlight) {
        [[NSColor grayColor] setFill];
        [NSBezierPath setDefaultLineWidth:5];
        [NSBezierPath fillRect:self.bounds];
    }
}

@end
