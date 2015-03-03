//
//  UnflipedViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 2/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "UnflipedViewController.h"

@interface UnflipedViewController ()

@end

@implementation UnflipedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(IBAction)shareFlip
{
    
    NSString *textToShare = @" Check out Flip - it's a marketplace for lease breaks and lease takeovers ";
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://appstore.com/%@",@"Flip"]];
    NSURL *url = [NSURL URLWithString:@"http://www.hiflip.com/"];
    
    NSArray *objectsToShare=@[url,textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
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
