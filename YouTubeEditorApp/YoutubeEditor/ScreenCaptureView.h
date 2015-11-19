//
//  ScreenCaptureView.h
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

/**
 * Delegate protocol.  Implement this if you want to receive a notification when the
 * view completes a recording.
 *
 * When a recording is completed, the ScreenCaptureView will notify the delegate, passing
 * it the path to the created recording file if the recording was successful, or a value
 * of nil if the recording failed/could not be saved.
 */
@protocol ScreenCaptureViewDelegate <NSObject>
- (void) recordingFinished:(NSString*)outputPathOrNil;
- (void) finallyCalled;
@end

/**
 * ScreenCaptureView, a UIView subclass that periodically samples its current display
 * and stores it as a UIImage available through the 'currentScreen' property.  The
 * sample/update rate can be configured (within reason) by setting the 'frameRate'
 * property.
 *
 * This class can also be used to record real-time video of its subviews, using the
 * 'startRecording' and 'stopRecording' methods.  A new recording will overwrite any
 * previously made recording file, so if you want to create multiple recordings per
 * session (or across multiple sessions) then it is your responsibility to copy/back-up
 * the recording output file after each session.
 *
 * To use this class, you must link against the following frameworks:
 *
 *  - AssetsLibrary
 *  - AVFoundation
 *  - CoreGraphics
 *  - CoreMedia
 *  - CoreVideo
 *  - QuartzCore
 *
 */

@interface ScreenCaptureView : UIView  <AVAudioRecorderDelegate> {
	//video writing
	AVAssetWriter *videoWriter;
	AVAssetWriterInput *videoWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
    AVAudioRecorder *recorder;
    
	NSDate* startedAt;
	void* bitmapData;
}

//for recording video
- (bool) startRecordingVideo;
- (void) stopRecordingVideo;

//for accessing the current screen and adjusting the capture rate, etc.
@property(retain) UIImage* currentScreen;
@property(assign) float frameRate;
@property(nonatomic, assign) id<ScreenCaptureViewDelegate> delegate;
@property(nonatomic, retain) MPMoviePlayerController *youtubePlayer;
@property(nonatomic, assign) CGSize naturalSize;
@property(nonatomic, retain) AVAssetImageGenerator *generate1;

//recording state
@property(nonatomic, assign) BOOL recording;

@end