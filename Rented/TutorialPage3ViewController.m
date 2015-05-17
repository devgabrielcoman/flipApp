//
//  TutorialPage3ViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "TutorialPage3ViewController.h"

@interface TutorialPage3ViewController ()

@end

@implementation TutorialPage3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UISwipeGestureRecognizer* swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)swipeRight:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)cancelButtonTapped:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)loginWithFacebook:(id)sender
{
    [DEP.api.userApi authenticateUserWithFacebook:^(BOOL authenticated) {
        if (authenticated)
        {
            [[Mixpanel sharedInstance] track:@"Successful FB Login"];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeedData" object:nil];
            }];
        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:nil message:@"There was a problem logging in. Please allow Flip to access your Facebook profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    }];
}

@end
