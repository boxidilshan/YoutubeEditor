//
//  HomeViewCell.h
//  YoutubeEditor
//
//  Created by DMTC on 7/29/15.
//  Copyright (c) 2015 dmtc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *duration;

@end
