//
//  UserApi.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "UserApi.h"

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK.h>

@implementation UserApi


- (BOOL)userIsAuthenticated
{
    return ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]);
}

- (void)authenticateUserWithFacebook:(void (^)(BOOL authenticated))completionHandler
{
    NSArray *permissionsArray = @[@"user_about_me", @"user_location", @"user_friends", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user)
            completionHandler(NO);
        else
        {
            if (user.isNew)
            {
                [self loadRequiredUserData:^(BOOL success) {
                    completionHandler(YES);
                }];
            }
            
            completionHandler(YES);
        }
    }];
}

- (void)loadRequiredUserData:(void (^)(BOOL success))completionHandler
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            NSDictionary *userData = (NSDictionary *)result;
            
            [DEP.authenticatedUser setObject:userData[@"id"] forKey:@"facebookID"];
            [DEP.authenticatedUser setObject:userData[@"name"] forKey:@"username"];
            if([[userData allKeys] containsObject:@"location"])
                [DEP.authenticatedUser setObject:userData[@"location"][@"name"] forKey:@"location"];
            else
                [DEP.authenticatedUser setObject:@"(currently not available)" forKey:@"location"];
                
            [DEP.authenticatedUser setObject:userData[@"gender"] forKey:@"gender"];
            
            //set here listing status too
            [DEP.authenticatedUser setObject:@ListingNotRequested forKey:@"listingStatus"];
            
            [DEP.authenticatedUser setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]] forKey:@"profilePictureUrl"];
            
            [DEP.authenticatedUser saveInBackground];
        }
    }];
}

- (void)logoutUser
{
    [PFUser logOut];
}

- (void)getFacebookMutualFriendsWithFriend:(NSString *)userId completionHandler:(void (^)(NSArray *mutualFriends, BOOL succeeded))completion
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"context.fields(mutual_friends)", @"fields",
                            nil
                            ];
    FBSession *session = [PFFacebookUtils session];
    if(session.state == FBSessionStateOpen)
    {
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", userId]
                                     parameters:params
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                    NSLog(@"result: %@", result);
                                                }];
    }
}

@end
