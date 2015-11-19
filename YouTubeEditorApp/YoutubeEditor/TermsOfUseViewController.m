//
//  TermsOfUseViewController.m
//  YoutubeEditor
//
//  Created by Dilshan Edirisuriya on 9/25/12.
//  Copyright © 2015 Dilshan Edirisuriya. All rights reserved.
//

#import "TermsOfUseViewController.h"

@interface TermsOfUseViewController ()

@end

@implementation TermsOfUseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSURL *rtfUrl;
    if (_index == 3) {
        self.title = @"How To Use";
        rtfUrl = [[NSBundle mainBundle] URLForResource:@"howtouse" withExtension:@"rtf"];
    }
    
    if (_index == 4) {
        self.title = @"Terms Of Use";
        rtfUrl = [[NSBundle mainBundle] URLForResource:@"termsofuse" withExtension:@"rtf"];
    }
    
    if (_index == 5) {
        self.title = @"Copyright";
        rtfUrl = [[NSBundle mainBundle] URLForResource:@"copyright" withExtension:@"rtf"];
    }
    
    if (_index == 6) {
        self.title = @"Privacy Policy";
        rtfUrl = [[NSBundle mainBundle] URLForResource:@"privacypolicy" withExtension:@"rtf"];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:rtfUrl];
    [_webView loadRequest:request];

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

@end
