//
//  UserApi.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "UserApi.h"

#import <AFNetworking/AFNetworking.h>
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
    NSArray *permissionsArray = @[@"user_about_me", @"user_friends", @"email"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user)
        {
            completionHandler(NO);
        }
        else
        {
            if (user.isNew)
            {
                [self loadRequiredUserData:^(BOOL success) {
                    
                    sleep(2);
                    [[Mixpanel sharedInstance] track:@"New User" properties:@{@"facebook_id":[PFUser currentUser][@"facebookID"]}];
                    [[Mixpanel sharedInstance] identify:[PFUser currentUser][@"facebookID"]];
                    if ([PFUser currentUser].email)
                    {
                        [[Mixpanel sharedInstance].people set:@{@"$email":[PFUser currentUser].email}];

                    }
                    [[Mixpanel sharedInstance].people set:@{@"$name":[PFUser currentUser].username}];
                    [[Mixpanel sharedInstance].people set:@{@"$first_name":[PFUser currentUser][@"firstName"]}];
                    [[Mixpanel sharedInstance].people set:@{@"$last_name":[PFUser currentUser][@"lastName"]}];

                    [[Mixpanel sharedInstance] setNameTag:[PFUser currentUser].username];
                    
                    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHostString]];
                    NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                             @"email": [PFUser currentUser].email};

                    AFHTTPRequestOperation *op = [manager POST:@"invite/check" parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        completionHandler(YES);
                        NSLog(@"JSON: %@", responseObject);
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        completionHandler(YES);
                        NSLog(@"Error: %@", error);
                    }];
                    [op start];
                }];
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                NSMutableArray* channels = [NSMutableArray new];
                [channels addObject:@"global" ];
                [channels addObject:user.objectId];
                
                currentInstallation.channels = channels;
                
                
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                }];

            }
            else
            {
                [[Mixpanel sharedInstance] identify:[PFUser currentUser][@"facebookID"]];
                if ([PFUser currentUser].email)
                {
                    [[Mixpanel sharedInstance].people set:@{@"$email":[PFUser currentUser].email}];
                }
                [[Mixpanel sharedInstance].people set:@{@"$name":[PFUser currentUser].username}];
                [[Mixpanel sharedInstance].people set:@{@"$first_name":[PFUser currentUser][@"firstName"]}];
                [[Mixpanel sharedInstance].people set:@{@"$last_name":[PFUser currentUser][@"lastName"]}];

                [[Mixpanel sharedInstance] setNameTag:[PFUser currentUser].username];
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
                        if(!error && objects && objects.count>0)
                        {
                            PFUser *userFriend = (PFUser*)[objects objectAtIndex:0];
                            FacebookFriend *fr = [FacebookFriend new];
                            fr.userId = friend;
                            fr.name = userFriend[@"firstName"];
                            fr.profilePictureUrl = userFriend[@"profilePictureUrl"];
                            
                            [DEP.facebookFriendsInfo setValue:fr forKey:friend];
                            
                        }
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
// Get all required information about logged user and set it to dependency container object
- (void)loadRequiredUserData:(void (^)(BOOL success))completionHandler
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            NSDictionary *userData = (NSDictionary *)result;
            
            if (userData[@"email"])
            {
                [DEP.authenticatedUser setObject:userData[@"email"] forKey:@"email"];
            }
            [DEP.authenticatedUser setObject:userData[@"id"] forKey:@"facebookID"];
            [DEP.authenticatedUser setObject:userData[@"first_name"] forKey:@"firstName"];
            [DEP.authenticatedUser setObject:userData[@"last_name"] forKey:@"lastName"];
            [DEP.authenticatedUser setObject:userData[@"name"] forKey:@"username"];
            if([[userData allKeys] containsObject:@"location"])
                [DEP.authenticatedUser setObject:userData[@"location"][@"name"] forKey:@"location"];
            else
            {
                if (!DEP.authenticatedUser[@"location"])
                {
                    [DEP.authenticatedUser setObject:@"(currently not available)" forKey:@"location"];
                }
            }
            
            [DEP.authenticatedUser setObject:userData[@"gender"] forKey:@"gender"];
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isFacebookProfileHidden"];
            
            //set here listing status too
            [DEP.authenticatedUser setObject:@ListingNotRequested forKey:@"listingStatus"];
            
            [DEP.authenticatedUser setObject:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", userData[@"id"]] forKey:@"profilePictureUrl"];
            
            [DEP.authenticatedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [(DashboardViewController*)delegate.rootViewController.leftPanel updateProfileData];
            }];
            
            [self getCurrentUsersFacebookFriends:^(NSArray *friends, BOOL succeeded) {
                
                [[PFUser currentUser] setObject:friends forKey:@"facebookFriends"];
                [[PFUser currentUser] saveInBackground];
                
            }];
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isVerified"];
            [DEP.authenticatedUser setObject:[NSNumber numberWithInt:0] forKey:@"isAdmin"];

            PFObject* object = [PFObject objectWithClassName:@"UserMetaData"];
            object[@"user"] = DEP.authenticatedUser;
            object[@"isVerified"]= [NSNumber numberWithInt:0];
            object[@"acceptedInvitesCount"]= [NSNumber numberWithInt:0];
            object[@"hasAccess"]= [NSNumber numberWithBool:NO];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    completionHandler(YES);
            
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
