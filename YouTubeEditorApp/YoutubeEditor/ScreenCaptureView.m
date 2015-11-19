//
//  ScreenCaptureView.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "ScreenCaptureView.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ScreenCaptureView(Private)
- (void) writeVideoFrameAtTime:(CMTime)time;
@end

@implementation ScreenCaptureView

@synthesize currentScreen, frameRate, delegate;

- (void) initialize {
	// Initialization code
	self.clearsContextBeforeDrawing = YES;
	self.currentScreen = nil;
	self.frameRate = 30.0f;     //10 frames per seconds
	_recording = false;
	videoWriter = nil;
	videoWriterInput = nil;
	avAdaptor = nil;
	startedAt = nil;
	bitmapData = NULL;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self initialize];
	}
	return self;
}

//static int frameCount = 0;            //debugging
- (void) drawRect:(CGRect)rect {
	NSDate* start = [NSDate date];
	
	//debugging
	//if (frameCount < 40) {
	//      NSString* filename = [NSString stringWithFormat:@"Documents/frame_%d.png", frameCount];
	//      NSString* pngPath = [NSHomeDirectory() stringByAppendingPathComponent:filename];
	//      [UIImagePNGRepresentation(self.currentScreen) writeToFile: pngPath atomically: YES];
	//      frameCount++;
	//}
	
	//NOTE:  to record a scrollview while it is scrolling you need to implement your UIScrollViewDelegate such that it calls
	//       'setNeedsDisplay' on the ScreenCaptureView.
	if (_recording) {
		float millisElapsed = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
		[self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000)];
	}
	
	float processingSeconds = [[NSDate date] timeIntervalSinceDate:start];
	float delayRemaining = (1.0 / self.frameRate) - processingSeconds;
	
	//CGContextRelease(context);
	
	//redraw at the specified framerate
	[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRemaining > 0.0 ? delayRemaining : 0.01];
}

- (void) cleanupWriter {
	avAdaptor = nil;
	videoWriterInput = nil;
	videoWriter = nil;
	startedAt = nil;
	
	if (bitmapData != NULL) {
		free(bitmapData);
		bitmapData = NULL;
	}
}

- (void)dealloc {
	[self cleanupWriter];
}

- (NSURL*) tempFileURL {
	NSString* outputPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"output.mp4"];
	NSURL* outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:outputPath]) {
		NSError* error;
		if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
			NSLog(@"Could not delete old recording file at path:  %@", outputPath);
		}
	}
	
	return outputURL;
}

-(BOOL) setUpWriter {
    
//    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:_youtubePlayer.contentURL options:nil];
//    _generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
//    _generate1.appliesPreferredTrackTransform = YES;

//    [_firstImage setImage:one];
//    _firstImage.contentMode = UIViewContentModeScaleAspectFit;
    
	NSError* error = nil;
	videoWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL] fileType:AVFileTypeQuickTimeMovie error:&error];
	NSParameterAssert(videoWriter);
	
	//Configure video
	NSDictionary* videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithDouble:1960000], AVVideoAverageBitRateKey,
                                           [NSNumber numberWithInt:1],AVVideoMaxKeyFrameIntervalKey,
										   nil ];
    
    if (CGSizeEqualToSize(CGSizeZero, _naturalSize)) {
        _naturalSize = _youtubePlayer.view.frame.size;
    }
    
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
								   AVVideoCodecH264, AVVideoCodecKey,
								   [NSNumber numberWithInt:_naturalSize.width], AVVideoWidthKey,
								   [NSNumber numberWithInt:_naturalSize.height], AVVideoHeightKey,
								   videoCompressionProps, AVVideoCompressionPropertiesKey,
								   nil];
	
    videoWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
	
	NSParameterAssert(videoWriterInput);
	videoWriterInput.expectsMediaDataInRealTime = YES;
	NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    avAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
	
	//add input
	[videoWriter addInput:videoWriterInput];
    
	[videoWriter startWriting];
	[videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    
	return YES;
}

- (void) completeRecordingSession {
	[videoWriterInput markAsFinished];
	
	// Wait for the video
	int status = videoWriter.status;
	while (status == AVAssetWriterStatusUnknown) {
		NSLog(@"Waiting...");
		[NSThread sleepForTimeInterval:0.5f];
		status = videoWriter.status;
	}
	
	@synchronized(self) {
        [videoWriter finishWritingWithCompletionHandler:^(){
            NSLog (@"finished writing");
        }];
		
		[self cleanupWriter];
		
        @try {
            [self CompileFilesToMakeMovie];
        }
        @catch (NSException *exception) {
            NSLog(@"..");
        }
        @finally {
            [self.delegate finallyCalled];
        }
        
	}
}

- (bool) startRecordingVideo {
	bool result = NO;
	@synchronized(self) {
		if (! _recording) {
			result = [self setUpWriter];
			startedAt = [NSDate date];
			_recording = true;
            [self startAudioRecording];
		}
	}
	
	return result;
}

- (void) stopRecordingVideo {
	@synchronized(self) {
		if (_recording) {
			_recording = false;
            [self stopAudioRecording];
			[self completeRecordingSession];
		}
	}
}

-(void) writeVideoFrameAtTime:(CMTime)time {
	if (![videoWriterInput isReadyForMoreMediaData]) {
		NSLog(@"Not ready for video data");
	}
	else {
		@synchronized (self) {
			//UIImage* newFrame = [self.currentScreen retain];
            UIImage* newFrame = [_youtubePlayer thumbnailImageAtTime:[_youtubePlayer currentPlaybackTime] timeOption:MPMovieTimeOptionExact];
            
            newFrame= [self drawText:@"Some text" inImage:newFrame atPoint:CGPointMake(0, 0)];

//            NSError *err = NULL;
//            CMTime time = CMTimeMakeWithSeconds([_youtubePlayer currentPlaybackTime], 1000000); ;
//            CGImageRef oneRef = [_generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
//            UIImage *newFrame = [[UIImage alloc] initWithCGImage:oneRef];
            
            @try {
                CGImageRef cgImage = CGImageCreateCopy([newFrame CGImage]);
                CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:cgImage size:[newFrame size]];
                
                BOOL success = [avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];
                if (!success)
                    NSLog(@"Warning:  Unable to write buffer to video");
                
                //clean up
                CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
                CVPixelBufferRelease( pixelBuffer );
                CGImageRelease(cgImage);
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }

		}
		
	}
	
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UITextView *myText = [[UITextView alloc] init];
    
    if(image.size.width <= 640) {
        myText.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:10.0f];
        
        myText.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        myText.text = @"This video was downloaded using YouTubeEditor App";
        myText.backgroundColor = [UIColor lightGrayColor];
        
        CGSize maximumLabelSize = CGSizeMake(400,50);
        CGSize expectedLabelSize = [myText.text sizeWithFont:myText.font
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:UILineBreakModeWordWrap];
        
        myText.frame = CGRectMake((image.size.width/2 - expectedLabelSize.width/2 ),
                                  5,
                                  400,
                                  50);
    } else {
        myText.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:24.0f];
        
        myText.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        myText.text = @"This video was downloaded using YouTubeEditor App";
        myText.backgroundColor = [UIColor lightGrayColor];
        
        CGSize maximumLabelSize = CGSizeMake(image.size.width,image.size.height);
        CGSize expectedLabelSize = [myText.text sizeWithFont:myText.font
                                           constrainedToSize:maximumLabelSize
                                               lineBreakMode:UILineBreakModeWordWrap];
        
        myText.frame = CGRectMake((image.size.width/2 - expectedLabelSize.width/2 ),
                                  5,
                                  image.size.width,
                                  image.size.height);
    }
    
    [[UIColor lightGrayColor] set];
    [myText.text drawInRect:myText.frame withFont:myText.font];
    UIImage *myNewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return myNewImage;
}

//- (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
//{
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    CVPixelBufferRef pxbuffer = NULL;
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width,
//                                          size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
//                                          &pxbuffer);
//    status=status;//Added to make the stupid compiler not show a stupid warning.
//    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
//    
//    CVPixelBufferLockBaseAddress(pxbuffer, 0);
//    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
//    NSParameterAssert(pxdata != NULL);
//    
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
//                                                 size.height, 8, 4*size.width, rgbColorSpace,
//                                                 kCGImageAlphaNoneSkipFirst);
//    NSParameterAssert(context);
//    
//    //CGContextTranslateCTM(context, 0, CGImageGetHeight(image));
//    //CGContextScaleCTM(context, 1.0, -1.0);//Flip vertically to account for different origin
//    
//    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//                                           CGImageGetHeight(image)), image);
//    CGColorSpaceRelease(rgbColorSpace);
//    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
//    
//    return pxbuffer;
//}

- (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size
{
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image),
                                  CGImageGetHeight(image));
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGImageCompatibilityKey,
     [NSNumber numberWithBool:YES],
     kCVPixelBufferCGBitmapContextCompatibilityKey,
     nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status =
    CVPixelBufferCreate(
                        kCFAllocatorDefault, frameSize.width, frameSize.height,
                        kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                        &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 pxdata, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGBitmapByteOrder32Big |
                                                 kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)startAudioRecording {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSString *outputPathAudio = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"audio.m4a"];
    NSURL *outputFileURL = [[NSURL alloc] initFileURLWithPath:outputPathAudio];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
    [recorder prepareToRecord];
    
    [session setActive:YES error:nil];
    
    [recorder record];
}

- (void)stopAudioRecording {
    [recorder stop];
    
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setActive:NO error:nil];
}

-(void)CompileFilesToMakeMovie
{
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition] ;
    
    NSString *outputPathAudio = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"audio.m4a"];
    NSURL *audio_inputFileUrl = [[NSURL alloc] initFileURLWithPath:outputPathAudio];
        
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"output.mp4"];
    NSURL *video_inputFileUrl = [[NSURL alloc] initFileURLWithPath:outputPath];

    NSString *finalPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"final.mov"];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:finalPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:finalPath])
        [[NSFileManager defaultManager] removeItemAtPath:finalPath error:nil];
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         id delegateObj = self.delegate;
         
         NSLog(@"Completed recording, file is stored at:  %@", outputFileUrl);
         if ([delegateObj respondsToSelector:@selector(recordingFinished:)]) {
             [delegateObj performSelectorOnMainThread:@selector(recordingFinished:) withObject:outputFileUrl waitUntilDone:YES];
         }
     }       
     ];  
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{

}

@end