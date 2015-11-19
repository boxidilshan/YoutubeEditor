//
//  ResultsViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "ResultsViewController.h"
#import "HomeViewCell.h"
#import "HCYoutubeParser.h"
#import "PlayerViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  92;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return [_resultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"HomeViewCell";
    
    HomeViewCell *cell = (HomeViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ResultDTO *resultDTO = [_resultArray objectAtIndex:indexPath.row];
    
    cell.title.text = resultDTO.title;
    cell.lblDate.text = resultDTO.channelTitle;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ResultDTO *resultDTO = [_resultArray objectAtIndex:indexPath.row];
    
//    NSString *unescapedString = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", resultDTO.videoID];
//    NSString * escapedUrlString =(NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
//                                                        NULL,
//                                                        (CFStringRef)unescapedString,
//                                                        NULL,
//                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                        kCFStringEncodingUTF8 ));
    
    NSString *youtubeURL = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", resultDTO.videoID];
    
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:youtubeURL]];
    
    UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PlayerViewController *playerViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PlayerView"];
    playerViewController.playerURL = [NSURL URLWithString:[videos objectForKey:@"medium"]];
    [self.navigationController presentViewController:playerViewController animated:TRUE completion:Nil];

}

@end
