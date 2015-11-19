//
//  AppDelegate.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVAudioSession.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Appirater.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [Appirater setAppId:@"284882215"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:0];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];

    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"%i",[group numberOfAssets]);
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %i",error.code);
        }else{
            NSLog(@"Other error code: %i",error.code);
        }
    }];
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            // Microphone enabled code
        }
        else {

        }
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc postNotificationName:@"MediaPlayerClose" object:self userInfo:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
//        if (granted) {
//            // Microphone enabled code
//        }
//        else {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Microphone Disabled" message:@"Please go to settings and scroll down to find Youtube Editor app to enable the Microphone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [alertView show];
//        }
//    }];
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    if (![userDefaults boolForKey:@"MOVIE_VIEW_MODE"]) {
//        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
//        switch (status) {
//            case ALAuthorizationStatusNotDetermined: {
//                // not determined
//                break;
//            }
//            case ALAuthorizationStatusRestricted: {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving To Photos Restricted" message:@"Please go to settings and scroll down to find Youtube Editor app to enable saving to Photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//                break;
//            }
//            case ALAuthorizationStatusDenied: {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Saving To Photos Disabled" message:@"Please go to settings and scroll down to find Youtube Editor app to enable saving to Photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//                break;
//            }
//            case ALAuthorizationStatusAuthorized: {
//                // authorized
//                break;
//            }
//            default: {
//                break;
//            }
//        }
//    }
    
//    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
//    
//    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//        NSLog(@"%i",[group numberOfAssets]);
//    } failureBlock:^(NSError *error) {
//        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
//            NSLog(@"user denied access, code: %i",error.code);
//        }else{
//            NSLog(@"Other error code: %i",error.code);
//        }
//    }];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
