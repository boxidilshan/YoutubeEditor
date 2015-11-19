//
//  TermsViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Terms Of Use";
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setShowsTouchWhenHighlighted:TRUE];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *barBackItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.hidesBackButton = TRUE;
    self.navigationItem.leftBarButtonItem = barBackItem;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:@"AGREED"]) {
        _btnAgree.hidden = TRUE;
    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:TRUE];
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

- (IBAction)clickOnAgree:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"AGREED" forKey:@"AGREED"];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
