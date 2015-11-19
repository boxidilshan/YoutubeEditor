//
//  MasterViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "MasterViewController.h"
#import "HomeViewCell.h"
#import "AppDelegate.h"
#import "SearchBarViewController.h"
#import "ResultDTO.h"
#import "ResultsViewController.h"
#import "PlayerViewController.h"
#import "HCYoutubeParser.h"
#import "TermsViewController.h"
#import "SettingsTableViewController.h"

@implementation MasterViewController

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Youtube Editor";

    _apiKey = @"AIzaSyD6F5Oyymo56zlASVLaXxvniv29cbfr6g0";
    
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *searchImage = [UIImage imageNamed:@"search.png"];
    [btnSearch setBackgroundImage:searchImage forState:UIControlStateNormal];
    btnSearch.frame = CGRectMake(0.0, 0.0, 25, 25);
    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    [btnSearch addTarget:self action:@selector(openSearchBar:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem = searchBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchVideos:)
                                                 name:@"SearchVideos"
                                               object:nil];
    
    UIButton *btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *refreshImage = [UIImage imageNamed:@"settings.png"];
    [btnRefresh setBackgroundImage:refreshImage forState:UIControlStateNormal];
    btnRefresh.frame = CGRectMake(0.0, 0.0, 25, 25);
    UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
    [btnRefresh addTarget:self action:@selector(loadSettings) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = settingsBarButtonItem;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor darkGrayColor];
    [self.refreshControl addTarget:self action:@selector(refreshVideos) forControlEvents:UIControlEventValueChanged];
    
    [self refreshVideos];
    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    if (![userDefaults objectForKey:@"AGREED"]) {
//        UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//        TermsViewController *termsViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TermsView"];
//        [self.navigationController presentViewController:termsViewController animated:FALSE completion:nil];
//    }

    
}

- (void)loadSettings {
    
    UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SettingsTableViewController *settingsTableViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SettingsView"];
    [self.navigationController pushViewController:settingsTableViewController animated:TRUE];
}

- (void)refreshVideos {
    [self loadFromKeyword:0];
}

-(void)searchVideos:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"SearchVideos"])
    {
        NSDictionary* userInfo = notification.userInfo;
        _keyword = (NSString*)userInfo[@"keyword"];
        
        [self loadFromKeyword:1];
    }
}

- (void)openSearchBar:(id)sender {
    UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    SearchBarViewController *searchBarViewController = [storyBoard instantiateViewControllerWithIdentifier:@"SearchBar"];
    //FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:searchBarViewController];
    //popover.contentSize = CGSizeMake(width, 60);
    //[popover presentPopoverFromView:sender];
    
    searchBarViewController.modalPresentationStyle = UIModalPresentationCustom;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController presentViewController:searchBarViewController animated:FALSE completion:nil];
    searchBarViewController.searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"SEARCH_STRING"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFromKeyword:(int)index {
    
    NSString *endpoint;
    
    if (index == 0) {
        endpoint = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&chart=mostPopular&type=video&maxResults=25&key=%@", _apiKey];
    } else if (index == 1) {
        
        NSString *searchKeyword =(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                NULL,
                                                                (CFStringRef)_keyword,
                                                                NULL,
                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                kCFStringEncodingUTF8 ));
        
        endpoint = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&maxResults=25&key=%@&order=relevance", searchKeyword, _apiKey];
    }
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self showConnectivityAlert];
        } else {
            _connectivityIssue = FALSE;
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data
                                                                       options: NSJSONReadingMutableContainers
                                                                         error: &error];
            
            if([returnDict objectForKey:@"items"]) {
                
                NSArray *itemsArray = [returnDict objectForKey:@"items"];
                
                if(itemsArray && [itemsArray count] == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"No results found for your search query" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        alertView.tag = 102;
                        [alertView show];
                    });
                    return;
                }
                
                _resultDTOArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *item in itemsArray) {
                    
                    NSDictionary *snippet = [item objectForKey:@"snippet"];
                    NSDictionary *identifier = [item objectForKey:@"id"];
                    
                    ResultDTO *resultDTO = [[ResultDTO alloc] init];
                    
                    if(snippet) {
                        [resultDTO setTitle:[snippet objectForKey:@"title"]];
                        
                        if ([snippet objectForKey:@"thumbnails"] && [[snippet objectForKey:@"thumbnails"] objectForKey:@"default"]) {
                            NSDictionary *urlDict = [[snippet objectForKey:@"thumbnails"] objectForKey:@"default"];
                            
                            [resultDTO setImageURL:[urlDict objectForKey:@"url"]];
                        }
                        
                        [resultDTO setPublishedDate:[snippet objectForKey:@"publishedAt"]];
                        [resultDTO setChannelTitle:[snippet objectForKey:@"channelTitle"]];
                        
                    }
                    
                    if (identifier) {
                        [resultDTO setVideoID:[identifier objectForKey:@"videoId"]];
                    }
                    
                    [_resultDTOArray addObject:resultDTO];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.tableView.userInteractionEnabled = NO;
                    [self.tableView reloadData];
                    [self.refreshControl endRefreshing];
                     self.tableView.userInteractionEnabled = YES;
                });
                
                NSString *videoIDs;
                
                int counter = 0;
                for (ResultDTO *resultDO in _resultDTOArray) {
                    
                    if (counter == 0) {
                        videoIDs = resultDO.videoID;
                    } else {
                        videoIDs = [NSString stringWithFormat:@"%@,%@", videoIDs, resultDO.videoID];
                    }
                    
                    counter++;
                }
                
                [self loadDurations:videoIDs];
            } else {
                [self showConnectivityAlert];
            }
        }
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 102)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"" forKey:@"SEARCH_STRING"];
        [userDefaults synchronize];
        
        [self refreshVideos];
    }
    else
    {
        //Do something else
    }
}

- (void)loadDurations:(NSString *)ids {

    NSString *endpoint = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?id=%@&part=contentDetails&key=%@", ids, _apiKey];
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self showConnectivityAlert];
        } else {
            NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:data
                                                                       options: NSJSONReadingMutableContainers
                   
                                                                         error: &error];
            
            if([returnDict objectForKey:@"items"]) {
                
                NSArray *itemsArray = [returnDict objectForKey:@"items"];
                NSMutableDictionary *idDictionary = [[NSMutableDictionary alloc] init];
                
                if(itemsArray) {

                    for (NSDictionary *item in itemsArray) {
                        
                        NSDictionary *contentDetails = [item objectForKey:@"contentDetails"];
                        
                        [idDictionary setObject:[contentDetails objectForKey:@"duration"] forKey:[item objectForKey:@"id"]];
                    }
                }
                
                NSMutableArray *newArray = [[NSMutableArray alloc] init];
                for (ResultDTO *resultDTO in _resultDTOArray) {
                    resultDTO.duration = [idDictionary objectForKey:resultDTO.videoID];
                    [newArray addObject:resultDTO];
                }
                
                _resultDTOArray = newArray;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });

            }
        }
    }];
}

- (void)showConnectivityAlert {
    _connectivityIssue = TRUE;
    [_resultDTOArray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure you are connected with internet in order to get videos from Youtube" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
    });
}

#pragma mark - TableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  92;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [_resultDTOArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"HomeViewCell";
    
    HomeViewCell *cell = (HomeViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([_resultDTOArray count] <= indexPath.row) {
        return cell;
    }
     
    ResultDTO *resultDTO = [_resultDTOArray objectAtIndex:indexPath.row];
    
    cell.title.text = resultDTO.title;
    cell.lblDate.text = resultDTO.channelTitle;
    
    if (resultDTO.duration) {
        NSTimeInterval interval = [self parseToTimeInterval:resultDTO.duration];
        
        if (interval) {
            cell.duration.text = [self stringFromTimeInterval:interval];
        }
    }
    if (resultDTO.image) {
        cell.image.image = resultDTO.image;
    } else {
        
        if (resultDTO.imageURL) {
            
            dispatch_async(kBgQueue, ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:resultDTO.imageURL]];
                if (imgData) {
                    UIImage *image = [UIImage imageWithData:imgData];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.image.image = image;
                            [resultDTO setImage:image];
                        });
                    }
                }
            });
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_resultDTOArray && [_resultDTOArray count] > 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        if (_connectivityIssue) {
            messageLabel.text = @"Please make sure you are connected with internet in order to get videos from Youtub.";
        } else {
            messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        }
        
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

-(NSTimeInterval)parseToTimeInterval:(NSString *)stringToParse {

    int days = 0, hours = 0, minutes = 0, seconds = 0;
    
    const char *ptr = [stringToParse cStringUsingEncoding:NSASCIIStringEncoding];
    while(*ptr)
    {
        if(*ptr == 'P' || *ptr == 'T')
        {
            ptr++;
            continue;
        }
        
        int value, charsRead;
        char type;
        if(sscanf(ptr, "%d%c%n", &value, &type, &charsRead) != 2)
            ;  // handle parse error
        if(type == 'D')
            days = value;
        else if(type == 'H')
            hours = value;
        else if(type == 'M')
            minutes = value;
        else if(type == 'S')
            seconds = value;
        else
            ;  // handle invalid type
        
        ptr += charsRead;
    }
    
    NSTimeInterval interval = ((days * 24 + hours) * 60 + minutes) * 60 + seconds;
    
    return interval;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResultDTO *resultDTO = [_resultDTOArray objectAtIndex:indexPath.row];
    
    if ([_resultDTOArray count] <= indexPath.row) {
        return;
    }
    
//    NSString *youtubeURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", resultDTO.videoID];
//    
//    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:youtubeURL]];
//    
    UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PlayerViewController *playerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PlayerView"];
    
//    playerViewController.playerURL = [NSURL URLWithString:[videos objectForKey:@"medium"]];

    playerViewController.videoID = resultDTO.videoID;
    [self.navigationController presentViewController:playerViewController animated:TRUE completion:Nil];
    
}



@end
