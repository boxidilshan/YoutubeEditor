//
//  SearchBarViewController.m
//  EquestrianClubRiyadh
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "SearchBarViewController.h"
#import "SemiModalAnimatedTransition.h"

@interface SearchBarViewController ()

@end

@implementation SearchBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor clearColor];
    
//    UIImage *cancelButtonImage = [UIImage imageNamed:@"cancel.png"];
//    cancelButtonImage = [cancelButtonImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundImage:cancelButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@""];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    
    _searchBar.showsCancelButton = TRUE;
    [_searchBar becomeFirstResponder];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:FALSE completion:nil];
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

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
    semiModalAnimatedTransition.presenting = YES;
    return semiModalAnimatedTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    SemiModalAnimatedTransition *semiModalAnimatedTransition = [[SemiModalAnimatedTransition alloc] init];
    return semiModalAnimatedTransition;
}

#pragma mark - search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
//    _searched = TRUE;
//    
//    [self sendSearchNotification];
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:searchBar.text forKey:@"SEARCH_STRING"];
//    [userDefaults synchronize];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searchBar.text forKey:@"SEARCH_STRING"];
    [userDefaults synchronize];
    
    [self sendSearchNotification];
    
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void)sendSearchNotification {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:_searchBar.text forKey:@"keyword"];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"SearchVideos" object:self userInfo:userInfo];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}


@end
