//
//  CVCAppDelegate.m
//  video-converter
//
//  Created by Carlos Ramos on 10/04/14.
//  Copyright (c) 2014 Carlos Ramos. All rights reserved.
//

#import "CVCAppDelegate.h"
#import "CVCDropDestinationView.h"
#import "CVCffmpegController.h"
#import "SMDoubleSlider.h"

static void *CVCPlayerRateContext = &CVCPlayerRateContext;

@interface CVCAppDelegate ()
@property (nonatomic, weak) IBOutlet NSTextField *dragLabel;
@property (nonatomic, weak) IBOutlet NSView *playerView;
@property (nonatomic, weak) IBOutlet CVCDropDestinationView *dropDestination;
@property (nonatomic, weak) IBOutlet NSTextField *startTextField;
@property (nonatomic, weak) IBOutlet NSTextField *endTextField;
@property (nonatomic, weak) IBOutlet NSButton *playButton;

@property (nonatomic, weak) IBOutlet SMDoubleSlider *doubleSlider;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation CVCAppDelegate {
    CMTime endTime;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(URLFromDrag:) name:FileURLDroppedNotification object:nil];
    
    
    [self.doubleSlider setMinValue:0.0];
    [self.doubleSlider setMaxValue:100.0];
    
    self.videoEnd = @100.0;
    
    NSDictionary *options = @{
                              NSAllowsEditingMultipleValuesSelectionBindingOption: @YES,
                              NSConditionallySetsEnabledBindingOption: @YES,
                              NSRaisesForNotApplicableKeysBindingOption: @YES
                              };
    [_doubleSlider bind:@"objectLoValue" toObject:self withKeyPath:@"self.videoStart" options:options];
    [_doubleSlider bind:@"objectHiValue" toObject:self withKeyPath:@"self.videoEnd" options:options];
}

- (void)URLFromDrag:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    NSURL *url = userinfo[@"URL"];
    NSAssert(url != nil, @"URL can't be nil");
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    
    if (!asset.isPlayable) {
        self.dragLabel.stringValue = @"File is not playable";
    } else {
        [self.dropDestination setHidden:YES];
        [self.dragLabel setHidden:YES];
        [self.playerView setHidden:NO];
        
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        [self.playerView setWantsLayer:YES];

        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.playerLayer setFrame:self.playerView.bounds];
        [self.playerView.layer addSublayer:self.playerLayer];
        
        __weak CVCAppDelegate *weakSelf = self;     // prevent retain cycle
        [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:NULL usingBlock:^(CMTime time) {
            CVCAppDelegate *strongSelf = weakSelf;  // prevent weakSelf from being released early
            [strongSelf willChangeValueForKey:@"videoStart"];
            // This will trigger the binding update
            [strongSelf didChangeValueForKey:@"videoStart"];
            [strongSelf willChangeValueForKey:@"currentStartTime"];
            [strongSelf didChangeValueForKey:@"currentStartTime"];

        }];
        
        
        
        self.player.muted = YES;
        
        [self.player addObserver:self forKeyPath:@"rate" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:CVCPlayerRateContext];
        
        [self.player play];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CVCPlayerRateContext) {
        if (self.player.rate > 0.0) {
            [self.playButton setTitle:@"Pause"];
        } else {
            [self.playButton setTitle:@"Play"];
        }
    }
}

- (IBAction)buttonAction:(id)sender
{
    // not implemented
    [[CVCffmpegController new] callFFMPEG];
}

- (NSNumber *)videoEnd
{
    if (self.player) {
        return @(CMTimeGetSeconds(endTime) * 100.0 / CMTimeGetSeconds(self.player.currentItem.duration));
    } else {
        return nil;
    }
}

- (void)setVideoEnd:(NSNumber *)videoEnd
{
    if (self.player) {
        double val = videoEnd.doubleValue/100.0 * CMTimeGetSeconds(self.player.currentItem.duration);
        endTime = CMTimeMakeWithSeconds(val, 1);
        [self willChangeValueForKey:@"currentEndTime"];
        [self didChangeValueForKey:@"currentEndTime"];
    }
}

- (NSNumber *)videoStart
{
    if (self.player) {
        return @(CMTimeGetSeconds(self.player.currentTime) * 100.0 / CMTimeGetSeconds(self.player.currentItem.duration));
    } else {
        return nil;
    }
}

- (IBAction)play:(id)sender
{
    if (self.player.rate > 0.0) {
        [self.player pause];
    } else {
        [self.player play];
    }
    
}

- (void)setVideoStart:(NSNumber *)videoStart
{
    if (self.player) {
        double val = videoStart.doubleValue/100.0 * CMTimeGetSeconds(self.player.currentItem.duration);
        [self.player seekToTime:CMTimeMakeWithSeconds(val, 1)];
        [self.player pause];
        [self willChangeValueForKey:@"currentStartTime"];
        [self didChangeValueForKey:@"currentStartTime"];
    }
}

- (NSString *)currentStartTime
{
    if (self.player) {
        return [self stringFromSeconds:CMTimeGetSeconds(self.player.currentTime)];
    } else {
        return nil;
    }
}

- (NSString *)currentEndTime
{
    if (self.player) {
        CMTime difference = CMTimeSubtract(endTime, self.player.currentTime);
        return [self stringFromSeconds:CMTimeGetSeconds(difference)];
    } else {
        return nil;
    }
}

- (NSString *)stringFromSeconds:(double)dSeconds
{
    int hours, minutes, seconds, milliseconds;
    
    milliseconds = (int)round(dSeconds * 1000) % 1000;
    minutes = (int)floor(dSeconds) / 60;
    hours = minutes / 60;
    if (hours > 0)
        minutes = minutes % 60;
    seconds = (int)floor(dSeconds) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds];
}

@end
