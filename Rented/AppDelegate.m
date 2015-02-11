//
//  AppDelegate.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "AppDelegate.h"

#pragma mark - FB and Parse dependecies

#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK.h>

#pragma mark - Other Dependecies
#import "RentedPanelController.h"
#import "FeedViewController.h"
#import "AuthenticationViewController.h"
#import "DashboardViewController.h"
#import <AFNetworking.h>
#import "NoInternetConnectionView.h"
#import "FacebookFriend.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self setupDataConnectionNotifier];
    [self setupParse];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _rootViewController = [RentedPanelController new];
    _rootViewController.allowRightSwipe = NO;
    _rootViewController.allowLeftSwipe = NO;
    _rootViewController.bounceOnCenterPanelChange = NO;
    _rootViewController.bounceOnSidePanelClose = NO;
    _rootViewController.bounceOnSidePanelOpen = NO;
    _rootViewController.shouldDelegateAutorotateToVisiblePanel = NO;
    _rootViewController.leftFixedWidth = 260.0f;
    _rootViewController.leftPanel = [DashboardViewController new];
    _rootViewController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:[FeedViewController new]];
    _rootViewController.rightPanel = nil;
    
    self.window.rootViewController = _rootViewController;
    
    [self.window makeKeyAndVisible];
    
    //check if the user is loggedin
    if([DEP.api.userApi userIsAuthenticated])
    {
        //get the user's updated friend list
        [DEP.api.userApi getCurrentUsersFacebookFriends:^(NSArray *friends, BOOL succeeded) {
            
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
    


    }

    
    return YES;
}

- (void)setupDataConnectionNotifier
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown)
         {
             [NoInternetConnection displayNoInternetConnection];
         }
         else
         {
             [NoInternetConnection internetConnectionAvailable];
         }
     }];
}

- (void)setupParse
{
#pragma warning - Check the warning with enableLocalDatastore and initializeFacebook
    //[Parse enableLocalDatastore];
    [Parse setLogLevel:PFLogLevelError];
    [Parse setApplicationId:ParseApplicationID
                  clientKey:ParseCliendKey];
    [PFFacebookUtils initializeFacebook];
}

- (void)setGeneralStyle
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

#pragma mark - Facebook Authentication Delegates

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

@end
