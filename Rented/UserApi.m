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
#import "AppDelegate.h"
#import "RentedPanelController.h"
#import "DashboardViewController.h"

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
            
            [self getCurrentUsersFacebookFriends:^(NSArray *friends, BOOL succeeded) {
               
                [[PFUser currentUser] setObject:friends forKey:@"facebookFriends"];
                [[PFUser currentUser] saveInBackground];
                
                DEP.facebookFriendsInfo = [NSMutableDictionary new];
                for (NSString *friend in friends)
                {
                    
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"facebookID" equalTo:friend];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if(!error)
                        {
                            PFUser *userFriend = (PFUser*)[objects objectAtIndex:0];
                            FacebookFriend *fr = [FacebookFriend new];
                            fr.userId = friend;
                            fr.name = userFriend[@"username"];
                            fr.profilePictureUrl = userFriend[@"profilePictureUrl"];
                            
                            [DEP.facebookFriendsInfo setValue:fr forKey:friend];
                            
                        }
                    }];

                }
                
            }];
            
            
            PFQuery * query = [PFQuery queryWithClassName:@"UserMetaData"];
            [query whereKey:@"user"equalTo:DEP.authenticatedUser];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if ([objects count]==0)
                 {
                     PFObject* object = [PFObject objectWithClassName:@"UserMetaData"];
                     object[@"user"] = DEP.authenticatedUser;
                     object[@"isVerified"]= [NSNumber numberWithInt:0];
                     [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                      {
                          
                      }];
                 }
                 
                 
             }];
            
            if ([DEP.authenticatedUser[@"isAdmin"] integerValue]==1)
            {
                [(DashboardViewController*)[(RentedPanelController*)[(AppDelegate*)[UIApplication sharedApplication].delegate rootViewController] leftPanel] showAdminOptions:YES] ;
            }
            else
            {
                [(DashboardViewController*)[(RentedPanelController*)[(AppDelegate*)[UIApplication sharedApplication].delegate rootViewController] leftPanel] showAdminOptions:NO] ;
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
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isFacebookProfileHidden"];
            
            //set here listing status too
            [DEP.authenticatedUser setObject:@ListingNotRequested forKey:@"listingStatus"];
            
            [DEP.authenticatedUser setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]] forKey:@"profilePictureUrl"];
            
            [DEP.authenticatedUser saveInBackground];
            
            [self getCurrentUsersFacebookFriends:^(NSArray *friends, BOOL succeeded) {
                
                [[PFUser currentUser] setObject:friends forKey:@"facebookFriends"];
                [[PFUser currentUser] saveInBackground];
                
            }];
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isVerified"];
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isAdmin"];

            PFObject* object = [PFObject objectWithClassName:@"UserMetaData"];
            object[@"user"] = DEP.authenticatedUser;
            object[@"isVerified"]= [NSNumber numberWithInt:0];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
            
        }
    }];
}

- (void)logoutUser
{
    [[PFFacebookUtils session] closeAndClearTokenInformation];
    [[FBSession activeSession] closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
    [PFUser logOut];
}

- (void)getFacebookMutualFriendsWithFriend:(NSString *)userId completionHandler:(void (^)(NSArray *mutualFriends, BOOL succeeded))completion
{
    FBSession *session = [PFFacebookUtils session];
    if(session.state == FBSessionStateOpen || session.state == FBSessionStateOpenTokenExtended)
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"context.fields(mutual_friends)", @"fields",nil];
        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", @"762533787128928"]
                                     parameters:params
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if(!error)
                                  {
                                    
                                      if(result != nil && [[result allKeys] containsObject:@"context"])
                                      {
                                          NSArray *mutualFriends = [result valueForKeyPath:@"context.mutual_friends.data"];
                                          
                                          NSMutableArray *mutual = [NSMutableArray new];
                                          for (NSDictionary *friendData in mutualFriends)
                                          {
                                              FacebookFriend *fr = [FacebookFriend new];
                                              fr.userId = friendData[@"id"];
                                              fr.name = friendData[@"name"];
                                              fr.profilePictureUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fr.userId];
                                              
                                              [mutual addObject:fr];
                                          }
                                          
                                          completion(mutual, YES);
                                      }
                                      else
                                      {
                                          
                                          completion(@[], NO);
                                          
                                      }
                                  }
                                  else
                                      completion(@[], YES);
                              }];
    }
    else
        completion(@[], NO);
}

- (void)getCurrentUsersFacebookFriends:(void(^)(NSArray *friends, BOOL succeeded))completion
{
    FBSession *session = [PFFacebookUtils session];
    if(session.state == FBSessionStateOpen || session.state == FBSessionStateOpenTokenExtended)
    {
        FBRequest* friendsRequest = [FBRequest requestForMyFriends];
        [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {
            if(!error && [[result allKeys] containsObject:@"data"])
            {
                NSArray *friends = result[@"data"];
                
                NSMutableArray *userFriends = [NSMutableArray new];
                for (NSDictionary *friendData in friends)
                    [userFriends addObject:friendData[@"id"]];
                
                completion(userFriends, YES);
            }
            else
                completion(@[], NO);
        }];
    }
    else
        completion(@[], NO);
}

-(void)toggleVerifiedForUser: (PFUser*) user verified: (BOOL) verified
{
    int isVerified;
    if (verified)
    {
        isVerified=1;
    }
    else
    {
        isVerified=0;
    }

    PFQuery* query = [PFQuery queryWithClassName:@"UserMetaData"];
    [query whereKey:@"user" equalTo:user];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]>0)
        {
            [objects firstObject][@"isVerified"]= [NSNumber numberWithInt:isVerified];
            [(PFObject*)[objects firstObject] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
            }];
        }
    }];
}

- (void)getListOfUsers:(void (^)(NSArray *users, BOOL succeeded))completionHandler
{
    PFQuery *query = [PFUser query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            completionHandler(objects, YES);
        }
        else
            completionHandler(@[], NO);
    }];
}


@end
