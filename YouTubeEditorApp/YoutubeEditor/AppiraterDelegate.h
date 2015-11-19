//
//  AppiraterDelegate.h
//  Banana Stand
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Appirater;

@protocol AppiraterDelegate <NSObject>

@optional
-(void)appiraterDidDisplayAlert:(Appirater *)appirater;
-(void)appiraterDidDeclineToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRate:(Appirater *)appirater;
-(void)appiraterDidOptToRemindLater:(Appirater *)appirater;
-(void)appiraterWillPresentModalView:(Appirater *)appirater animated:(BOOL)animated;
-(void)appiraterDidDismissModalView:(Appirater *)appirater animated:(BOOL)animated;
@end
