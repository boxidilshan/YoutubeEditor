//
//  SettingsTableViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "TermsOfUseViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setShowsTouchWhenHighlighted:TRUE];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = barBackItem;
}

- (void)goBack {
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Email friend";
            break;
        case 1:
            cell.textLabel.text = @"Feedback or request more features";
            break;
        case 2:
            cell.textLabel.text = @"Copy YoutubeEditor iTunes URL";
            break;
        case 3:
            cell.textLabel.text = @"How to use";
            break;
        case 4:
            cell.textLabel.text = @"Terms of use";
            break;
        case 5:
            cell.textLabel.text = @"Copyright";
            break;
        case 6:
            cell.textLabel.text = @"Privacy policy";
            break;
        case 7: {
            
            UISwitch* s = [[UISwitch alloc] init];
            CGSize switchSize = [s sizeThatFits:CGSizeZero];
            s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                                 (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                 switchSize.width,
                                 switchSize.height);
            s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            s.tag = 100;
            [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [[cell.contentView viewWithTag:100]removeFromSuperview] ;
            [cell.contentView addSubview:s];
            
            UILabel* l = [[UILabel alloc] init];
            l.text = @"Movie View Mode";
            CGRect labelFrame = CGRectInset(cell.contentView.bounds, 10.0f, 8.0f);
            labelFrame.size.width = cell.contentView.bounds.size.width / 2.0f;
            labelFrame.origin.x = 30;
            l.font = [UIFont systemFontOfSize:17.0f];
            l.frame = labelFrame;
            l.backgroundColor = [UIColor clearColor];
            cell.accessibilityLabel = @"Movie View Mode";
            [cell.contentView addSubview:l];
            ((UISwitch*)[cell.contentView viewWithTag:100]).on = 100;
            
            [s setOnTintColor:[UIColor darkGrayColor]];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [s setOn:[userDefaults boolForKey:@"MOVIE_VIEW_MODE"]];
            
            break;
        }
        case 8: {
            cell.textLabel.text = @"Rate this App";
            break;
        }
    }
    
    [cell setIndentationLevel:1];
    
    return cell;
}

-(void) switchChanged:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:switcher.on forKey:@"MOVIE_VIEW_MODE"];
    [userDefaults synchronize];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0: {
            [self emailFriend];
            break;
        }
        case 1: {
            [self feedback];
            break;
        }
        case 2: {
            NSString *url = @"itunes://youtubeeditor";
            
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.URL = [NSURL URLWithString:url];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"URL copied" message:url delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            
            [self.tableView reloadData];
            
            break;
        }
        case 7: {

            break;
        }
        case 8: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://khanacademy.org"]];
            break;
        }
        default: {
            UIStoryboard *storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            TermsOfUseViewController *termsOfUseViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TermsOfUseViewController"];
            termsOfUseViewController.index = indexPath.row;
            [self.navigationController pushViewController:termsOfUseViewController animated:TRUE];
            break;
        }
    }
    
}

- (void)emailFriend {
    
    NSString *emailTitle = @"I love this app YoutubeEditor";
    NSString *messageBody = @"itunes://url";

    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
    mc.mailComposeDelegate = self;

    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void)feedback {
    
    NSString *emailTitle = @"YoutubeEditor App";
    NSArray *toRecipents = [NSArray arrayWithObject:@"supportyoutubeeditor@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
