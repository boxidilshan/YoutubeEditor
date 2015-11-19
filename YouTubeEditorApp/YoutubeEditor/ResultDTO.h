//
//  ResultDTO.h
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ResultDTO : NSObject

@property(nonatomic, retain) NSString *imageURL;
@property(nonatomic, retain) NSString *videoID;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *channelTitle;
@property(nonatomic, retain) NSString *publishedDate;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *duration;

@end
