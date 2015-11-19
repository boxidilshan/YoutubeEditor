//
//  PlayerViewController.h
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ScreenCaptureView.h"

@interface PlayerViewController : UIViewController <ScreenCaptureViewDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, retain) NSURL *playerURL;
@property(nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property(nonatomic, retain) IBOutlet ScreenCaptureView* captureView;
@property (assign, nonatomic) BOOL isRecording;
@property (strong, nonatomic) IBOutlet UIButton *btnRecord;
@property (strong, nonatomic) IBOutlet UIButton *btnPlay;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *loadingMessage;
@property (strong, nonatomic) IBOutlet UISlider *sliderView;
@property (assign, nonatomic) NSTimeInterval totalVideoTime;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSTimer *idleTimer;
@property (retain, nonatomic) NSTimer *recordingTimer;
@property (retain, nonatomic) NSTimer *streammingTimer;
@property (assign, nonatomic) BOOL playing;
@property (assign, nonatomic) BOOL playerInvalidated;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;
@property (retain, nonatomic) NSString *videoID;
@property (retain, nonatomic) UITapGestureRecognizer *singleFingerTap;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)recordButtonClicked:(id)sender;
- (IBAction)playButtonClicked:(id)sender;

@end
