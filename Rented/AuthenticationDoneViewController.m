//
//  AuthenticationDoneViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 5/11/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "AuthenticationDoneViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"

@interface AuthenticationDoneViewController ()

@end

@implementation AuthenticationDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"userId": [PFUser currentUser].objectId};
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
                        [self.rankingLabel setText:[NSString stringWithFormat:@"%d",[responseDict[@"authRanking"] intValue]-1]];
                    }
                    if([responseDict[@"status"] intValue] == 200)
                    {
                        [self.listContainer setHidden:YES];
                        [self.cityContainer setHidden:NO];
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
}

-(IBAction)inviteFriends:(id)sender
{

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/invite/accept/%@",kHostString,[PFUser currentUser].objectId] ];
    NSString *string = @"Just signed up for Flip - the easiest (and most profitable) way to find or transfer a lease";
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[URL,string]
                                      applicationActivities:nil];
    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                     }];
    
}


@end
