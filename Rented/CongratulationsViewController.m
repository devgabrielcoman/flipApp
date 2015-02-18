//
//  CongratulationsViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 2/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "CongratulationsViewController.h"

@interface CongratulationsViewController ()

@end

@implementation CongratulationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)shareButtonTapped:(id)sender
{
    NSString *textToShare = @"Check out this apartment!";
    
    NSURL *url = self.apartment[@"shareUrl"];
    UIImage* image = self.image;
    
    NSArray *objectsToShare;
    
    if (image)
    {
        objectsToShare = @[textToShare, url,image];
    }
    else
    {
        objectsToShare = @[textToShare, url,image];
        
    }
    
    
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

-(void)backButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
