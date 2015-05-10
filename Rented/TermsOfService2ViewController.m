//
//  TermsOfService2ViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TermsOfService2ViewController.h"

@interface TermsOfService2ViewController ()

@end

@implementation TermsOfService2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSURL *htmlFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tos" ofType:@"html"] isDirectory:NO];
    [self.webView loadRequest:[NSURLRequest requestWithURL:htmlFile]];
    
    // scroll to top
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(0,0);"];
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}
-(void)viewWillAppear:(BOOL)animated
{

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
