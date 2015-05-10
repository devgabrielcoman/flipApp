//
//  TermsOfServiceViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 3/15/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TermsOfServiceViewController.h"
#import "TermsOfService2ViewController.h"
#import "faqViewController.h"
#import "PrivacyPolicyViewController.h"

@interface TermsOfServiceViewController ()

@end

@implementation TermsOfServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @" ";

    if (!DEP.authenticatedUser)
    {
        [self.logoutButton setHidden:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)faqButtonTapped:(id)sender
{
    faqViewController* faqVC = [faqViewController new];
    [self.navigationController pushViewController:faqVC animated:YES];
}
-(IBAction)termsOfServiceButtonTapped:(id)sender
{
    TermsOfService2ViewController* tosVC=[TermsOfService2ViewController new];
    [self.navigationController pushViewController:tosVC animated:YES];
}
-(IBAction)privacyPolicyButtonTapped:(id)sender
{
    PrivacyPolicyViewController* privacyVC=[PrivacyPolicyViewController new];
    [self.navigationController pushViewController:privacyVC animated:YES];
}

-(IBAction)logoutButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.dashboardVC logoutUser:nil];
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
