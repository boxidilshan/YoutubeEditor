//
//  MasterViewController.h
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterViewController : UITableViewController

@property(nonatomic, retain) NSMutableArray *resultDTOArray;
@property(nonatomic, retain) NSString *keyword;
@property(nonatomic, retain) NSString *apiKey;
@property(nonatomic, retain) UIRefreshControl *refreshControl;
@property(nonatomic, assign) BOOL connectivityIssue;

@end

