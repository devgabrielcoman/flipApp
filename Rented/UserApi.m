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
#import "FacebookFriend.h"

@implementation UserApi


- (BOOL)userIsAuthenticated
{
    return ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]);
}

- (void)authenticateUserWithFacebook:(void (^)(BOOL authenticated))completionHandler
{
    NSArray *permissionsArray = @[@"user_about_me", @"user_location", @"user_friends", @"user_location", @"email"];
    
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
            
            [DEP.authenticatedUser setObject:userData[@"email"] forKey:@"email"];
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
    FBSession *session = [PFFacebookUtils session];
#warning not so efficient...just a solution for the moment..
    if(session.state == FBSessionStateOpen)
    {
        [FBRequestConnection startWithGraphPath:@"me/friends" parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if(!error)
            {
                NSMutableArray *myFriends = [NSMutableArray new];
                NSArray *myFacebookMutualFriends = result[@"data"];
                
                for (NSDictionary *userInfo in myFacebookMutualFriends)
                {
                    FacebookFriend *fr = [FacebookFriend new];
                    fr.userId = userInfo[@"id"];
                    fr.name = userInfo[@"name"];
                    fr.profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fr.userId];
                    
                    [myFriends addObject:fr];
                }
                
                [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/friends", userId]
                                             parameters:nil
                                             HTTPMethod:@"GET"
                                      completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                        if(!error)
                                        {
                                            NSMutableArray *friendsOfFriend = [NSMutableArray new];
                                            NSArray *facebookFriendsOfFriend = result[@"data"];
                                            
                                            for (NSDictionary *userInfo in facebookFriendsOfFriend)
                                            {
                                                FacebookFriend *fr = [FacebookFriend new];
                                                fr.userId = userInfo[@"id"];
                                                fr.name = userInfo[@"name"];
                                                fr.profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fr.userId];
                                                
                                                [friendsOfFriend addObject:fr];
                                            }
                                            
                                            NSMutableArray *finalArray = [NSMutableArray new];
                                            for (FacebookFriend *fr in myFriends)
                                            {
                                                if([friendsOfFriend containsObject:fr])
                                                   [finalArray addObject:fr];
                                            }
                                            
                                            completion(finalArray, YES);
                                        }
                                        else
                                        {
                                            completion(@[], NO);
                                        }
                                    }];
            }
            else
                completion(@[], NO);
        }];
    }
}

@end
