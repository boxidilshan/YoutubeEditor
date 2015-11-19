//
//  PlayerViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "PlayerViewController.h"
#import "XCDYouTubeVideoPlayerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PlayerViewController ()

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XCDYouTubeVideoPlayerViewController *videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:_videoID];
    [videoPlayerViewController presentInView:_captureView];
//    [videoPlayerViewController.moviePlayer play];
    
    _captureView.delegate = self;
    _isRecording = FALSE;
    
    //_moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_playerURL];
    _moviePlayer = videoPlayerViewController.moviePlayer;
    _captureView.youtubePlayer = _moviePlayer;
    
    _singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideControlsOnTapAction:)];
    [_moviePlayer.view removeGestureRecognizer:_singleFingerTap];
    [_moviePlayer.view addGestureRecognizer:_singleFingerTap];
    _singleFingerTap.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieNaturalSizeAvailable)
                                                 name:MPMovieNaturalSizeAvailableNotification
                                               object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activate) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.shouldAutoplay = YES;
    
    [_moviePlayer prepareToPlay];
    [_moviePlayer.view setFrame: self.view.bounds];
    [_captureView addSubview: _moviePlayer.view];
    
    _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [_moviePlayer play];
    [_moviePlayer setFullscreen:YES animated:YES];
    
    _playing = TRUE;
    
    [self startTimer];
    [_sliderView addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_btnClose];
    [self.view addSubview:_btnRecord];
    [self.view addSubview:_activityIndicator];
    [self.view addSubview:_loadingMessage];
    [self.view addSubview:_sliderView];
    [self.view addSubview:_btnPlay];
    [self.view addSubview:_lblTimer];
    
    [self startIdleTimer];
    
    [self startStreammingTimer];
}

-(void)appWillResignActive:(NSNotification*)note
{
    if (_playing) {
        _isRecording = FALSE;
        
        [_captureView stopRecordingVideo];
        
        [_btnRecord setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        
        [_recordingTimer invalidate];
        _lblTimer.hidden = TRUE;
        _lblTimer.text = @"0";
        
        [_moviePlayer pause];
        _playing = FALSE;
        [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(monitorPlaybackTime) userInfo:nil repeats:YES];
}

- (void)startIdleTimer {
    
    if ([_idleTimer isKindOfClass:[NSTimer class]] && [_idleTimer isValid]) {
        [_idleTimer invalidate];
        _idleTimer = nil;
    }
    
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
}

- (void)startStreammingTimer {
    
    if ([_streammingTimer isKindOfClass:[NSTimer class]] && [_streammingTimer isValid]) {
        [_streammingTimer invalidate];
        _streammingTimer = nil;
    }
    
    self.streammingTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(streamError) userInfo:nil repeats:NO];
}

- (void)endStreammingTimer {
    
    if ([_streammingTimer isKindOfClass:[NSTimer class]] && [_streammingTimer isValid]) {
        [_streammingTimer invalidate];
        _streammingTimer = nil;
    }
}

- (void)streamError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Error" message:@"Please check your internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag = 101;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101)
    {
        [self closeButtonClicked:nil];
    }
    else
    {
        //Do something else
    }
}

- (void)hideControls {
    _btnPlay.hidden = TRUE;
    _btnClose.hidden = TRUE;
    _sliderView.hidden = TRUE;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:@"MOVIE_VIEW_MODE"]) {
        _btnRecord.hidden = TRUE;
        _lblTimer.hidden = TRUE;
    }
    
    if ([_idleTimer isKindOfClass:[NSTimer class]] && [_idleTimer isValid]) {
        [_idleTimer invalidate];
    }
}

- (void)showControls {
    _btnPlay.hidden = FALSE;
    _btnClose.hidden = FALSE;
    _sliderView.hidden = FALSE;
    _btnRecord.hidden = FALSE;
    
    if (_isRecording) {
        _lblTimer.hidden = FALSE;
    }
    
    [self startIdleTimer];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"MOVIE_VIEW_MODE"]) {
        _btnRecord.hidden = TRUE;
        _lblTimer.hidden = TRUE;
    }
}

- (void)showHideControlsOnTapAction:(UIGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_btnPlay.hidden) {
            [self showControls];
        } else {
            [self hideControls];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)movieNaturalSizeAvailable {
    _captureView.naturalSize = _moviePlayer.naturalSize;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) playbackStateChanged {
    
    [_captureView performSelector:@selector(startRecordingVideo) withObject:nil afterDelay:1.0];
    [_captureView performSelector:@selector(stopRecordingVideo) withObject:nil afterDelay:10.0];
    
}

- (void)allowTap {
    
    [_moviePlayer play];
    _playing = TRUE;
    [_btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    
    [self showControls];
    
}

- (void)activate {
    
    [_moviePlayer pause];
    _playing = FALSE;
    [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    [self showControls];
    
    [self startIdleTimer];
    
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [self endStreammingTimer];
        [self showControls];
        [_activityIndicator stopAnimating];
        _loadingMessage.hidden = TRUE;
        _totalVideoTime = _moviePlayer.duration;
        
        [self allowTap];
    }
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    {
    }
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    {

    }
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStateInterrupted)
    { //interrupted
    }
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStateSeekingForward)
    { //seeking forward
    }
    
    if (_moviePlayer.playbackState == MPMoviePlaybackStateSeekingBackward)
    { //seeking backward
    }
    
}

- (void) moviePlayerLoadStateDidChange:(NSNotification *)notification
{
    MPMoviePlayerController *moviePlayerController = notification.object;
    NSMutableString *loadState = [NSMutableString new];
    MPMovieLoadState state = moviePlayerController.loadState;
    
    if (state & MPMovieLoadStatePlayable) {
        [self endStreammingTimer];
        [_activityIndicator stopAnimating];
        _loadingMessage.hidden = TRUE;
    } else if (state & MPMovieLoadStatePlaythroughOK) {
        [self endStreammingTimer];
        [_activityIndicator stopAnimating];
        _loadingMessage.hidden = TRUE;
    } else if (state & MPMovieLoadStateStalled) {
        [loadState appendString:@" | Stalled"];
    }
    
    NSLog(@"Load State: %@", loadState.length > 0 ? [loadState substringFromIndex:3] : @"N/A");
}

- (void) recordingFinished:(NSString*)outputPathOrNil {
    [self performSelectorOnMainThread:@selector(playSavedVideo) withObject:nil waitUntilDone:TRUE];
}

- (void) finallyCalled {
    _btnRecord.enabled = TRUE;
}

- (void)playSavedVideo {
    _btnRecord.enabled = TRUE;
    NSString* outputPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"final.mov"];
    UISaveVideoAtPathToSavedPhotosAlbum(outputPath, nil, nil, nil);
}


- (IBAction)closeButtonClicked:(id)sender {
    
    _playerInvalidated = TRUE;
    
    [self endStreammingTimer];
    if (_captureView.recording) {
        [_captureView stopRecordingVideo];
    }
    
    [_moviePlayer stop];
    
    [self dismissViewControllerAnimated:TRUE completion:Nil];
}

- (IBAction)recordButtonClicked:(id)sender {
    
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusNotDetermined: {
            // not determined
            break;
        }
        case ALAuthorizationStatusRestricted: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving To Photos Restricted" message:@"Please go to settings and scroll down to find Youtube Editor app to enable saving to Photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
            break;
        }
        case ALAuthorizationStatusDenied: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving To Photos Disabled" message:@"Please go to settings and scroll down to find Youtube Editor app to enable saving to Photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
            break;
        }
        case ALAuthorizationStatusAuthorized: {
            // authorized
            break;
        }
        default: {
            break;
        }
    }
    
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                [self recordButtonLogic];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Microphone Disabled" message:@"Please go to settings and scroll down to find Youtube Editor app to enable the Microphone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    
}

- (void)recordButtonLogic {
    if (!_playing) {
        [self playButtonClicked:nil];
    }
    
    if (_isRecording) {
        _isRecording = FALSE;
        
        _btnRecord.enabled = FALSE;
        [_captureView stopRecordingVideo];
        
        [_btnRecord setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
        
        [_recordingTimer invalidate];
        _lblTimer.hidden = TRUE;
        _lblTimer.text = @"0";
    } else {
        _isRecording = TRUE;
        
        [_captureView startRecordingVideo];
        
        [_btnRecord setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
        
        _recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
        _lblTimer.hidden = FALSE;
    }
    
    [self startIdleTimer];
}

-(void)countDown:(NSTimer *) aTimer {
    _lblTimer.text = [NSString stringWithFormat:@"%d",[_lblTimer.text intValue] + 1];
}

- (IBAction)playButtonClicked:(id)sender {

    if (_playing) {
        if (_isRecording) {
            [self recordButtonClicked:nil];
        }
        
        [_moviePlayer pause];
        _playing = FALSE;
        [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        
    } else {
        [_moviePlayer play];
        _playing = TRUE;
        [_btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    
    [self startIdleTimer];
}

- (void) monitorPlaybackTime
{
    if (_playerInvalidated) {
        [_moviePlayer stop];
       
        if ([_timer isKindOfClass:[NSTimer class]] && [_timer isValid]) {
            [_timer invalidate];
        }
        
        if ([_idleTimer isKindOfClass:[NSTimer class]] && [_idleTimer isValid]) {
            [_idleTimer invalidate];
        }
        
        if ([_recordingTimer isKindOfClass:[NSTimer class]] && [_recordingTimer isValid]) {
            [_recordingTimer invalidate];
        }
        
        if ([_streammingTimer isKindOfClass:[NSTimer class]] && [_streammingTimer isValid]) {
            [_streammingTimer invalidate];
        }
        
        return;
    }
    
    self.totalVideoTime = _moviePlayer.duration;
    self.sliderView.value = _moviePlayer.currentPlaybackTime / self.totalVideoTime;
    
    if ((_moviePlayer.currentPlaybackTime / self.totalVideoTime) >=  0.99) {
        
        _playing = TRUE;
        [_btnPlay setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        
        if (_isRecording) {
            [self recordButtonClicked:nil];
        }
        
        [_moviePlayer stop];
        [_moviePlayer prepareToPlay];
        [_moviePlayer play];
        
        [_moviePlayer setCurrentPlaybackTime:0];
        
        if ([_idleTimer isKindOfClass:[NSTimer class]] && [_timer isValid]) {
            [_idleTimer invalidate];
        }
        
        [self showControls];
        [self playButtonClicked:nil];
        
        _totalVideoTime = _moviePlayer.duration;
        self.sliderView.value = 0.0f;
    }
}

-(void)changeSlider:(id)sender{
    
    if ([_timer isKindOfClass:[NSTimer class]] && [_timer isValid]) {
        [_timer invalidate];
    }
    
    float sliderValue = (float)(_sliderView.value);
    
    [_moviePlayer setCurrentPlaybackTime:sliderValue * self.totalVideoTime];
    [self startTimer];
}

@end
