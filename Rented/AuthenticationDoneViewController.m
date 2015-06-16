//
//  AuthenticationDoneViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "AuthenticationDoneViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"
#import "CustomActivityItemProvider2.h"
#import <MessageUI/MessageUI.h>

@interface AuthenticationDoneViewController ()

@end

@implementation AuthenticationDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{

    if([DEP.api.userApi userIsAuthenticated])
    {
        
        NSString* city = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentCity"];
        
        if (city)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];

            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

            NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                     @"location": city};
            NSString* getURL = [NSString stringWithFormat:@"%@/login/status",kHostString];
            [manager GET:getURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                NSLog(@"JSON: %@", responseObject);
                
                NSDictionary* responseDict = (NSDictionary*)responseObject;
                if (!responseDict[@"error"])
                {
                    
                    if([responseDict[@"hasAccess"] boolValue])
                    {
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        if([responseDict[@"status"] intValue] == 100)
                        {
                            [self.listContainer setHidden:NO];
                            [self.cityContainer setHidden:YES];
                            [self.noLocationContainer setHidden:YES];
                            [self.rankingLabel setText:[NSString stringWithFormat:@"%d",[responseDict[@"authRanking"] intValue]-1]];
                        }
                        if([responseDict[@"status"] intValue] == 200)
                        {
                            [self.listContainer setHidden:YES];
                            [self.cityContainer setHidden:NO];
                            [self.noLocationContainer setHidden:YES];
                        }
                    }
                    
                    
                }
                else
                {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:responseDict[@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [[[UIAlertView alloc] initWithTitle:@"There was a server error" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }];
        }
        else
        {
            [self.listContainer setHidden:YES];
            [self.cityContainer setHidden:YES];
            [self.noLocationContainer setHidden:NO];
        }

    }
}

-(IBAction)inviteFriends:(id)sender
{

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/invite/accept/%@",kHostString,[PFUser currentUser].objectId] ];
    NSString *socialMediaString = @"Just signed up for Flip - the easiest (and most profitable) way to find or transfer a lease";
    NSString *emailString = @"Hey! I got you an invite to a new app called Flip, where people can buy and sell leases from each other. Thought you might want to get out of your lease on your apartment or office at some point soon, or even take one over if you’re looking to move.";
    
    CustomActivityItemProvider2* string = [[CustomActivityItemProvider2 alloc]initWithDefaultString:socialMediaString andEmailString:emailString];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[URL,string]
                                      applicationActivities:nil];
    activityViewController.CompletionHandler= ^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSMutableDictionary* properties = [NSMutableDictionary new];
            properties[@"method"]= [[activityType componentsSeparatedByString:@"."] lastObject];
            [[Mixpanel sharedInstance] track:@"Shared Referral Link" properties:properties];
        }
    };
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                     }];
    
}


-(IBAction)closeButtonTapped:(id)sender
{
    
    [DEP.api.userApi logoutUser];
    DEP.authenticatedUser = nil;
    
    [self.listContainer setHidden:YES];
    [self.cityContainer setHidden:YES];
    [self.noLocationContainer setHidden:YES];

    
    UINavigationController* authNavVC = [[UINavigationController alloc]initWithRootViewController:[AuthenticationViewController new]];
    [self presentViewController:authNavVC animated:YES completion:^{
           }];
}

-(IBAction)showEmailComposer:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Hello - I am actually in NYC and ..."];
        [mail setToRecipients:@[@"hello@leaseflip.co"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"This device cannot send email" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

@end
