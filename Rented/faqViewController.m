//
//  faqViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/18/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "faqViewController.h"

@interface faqViewController ()

@end

@implementation faqViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSURL *htmlFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"faq" ofType:@"html"] isDirectory:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlFile]];
    
    // scroll to top
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0);"];

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
