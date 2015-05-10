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
#import "SingleApartmentViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Mixpanel sharedInstanceWithToken:MixpanelKey];

    
    [[UINavigationBar appearance]setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:YES];
    
    NSURL* launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    
    [self setupDataConnectionNotifier];
    [self setupParse];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:1/255.0 green:39/255.0 blue:124/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0], NSFontAttributeName, nil]];
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
    
    if (launchURL)
    {
        NSString* launchURLString = [NSString stringWithFormat:@"%@",launchURL];
        NSArray* urlComponents = [launchURLString componentsSeparatedByString:@"//"];
        if ([urlComponents count] ==2)
        {
            NSString* parametersString = [urlComponents objectAtIndex:1];
            
            NSArray* parameters = [parametersString componentsSeparatedByString:@"/"];
            if ([parameters count] == 3)
            {
                NSString* type = [parameters objectAtIndex:1];
                
                if ([type isEqualToString:@"apartment"])
                {
                    NSString* param3 =[parameters objectAtIndex:2];
                    NSArray* param3Array =[param3 componentsSeparatedByString:@"?"];
                    NSString* apartmentId = [param3Array objectAtIndex:0];
                    SingleApartmentViewController* singleApartmentVC = [SingleApartmentViewController new];
                    singleApartmentVC.apartmentId = apartmentId;
                    _rootViewController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:singleApartmentVC];
                }
            }
            
        }
    }
    else
    {
        _rootViewController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:[FeedViewController new]];
    }

    _rootViewController.rightPanel = nil;
    
    self.window.rootViewController = _rootViewController;
    
    [self.window makeKeyAndVisible];
    
    [_rootViewController showLeftPanelAnimated:NO];
    
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
                    if(!error && objects && objects.count)
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

    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    [Fabric with:@[CrashlyticsKit]];
    
    [[Mixpanel sharedInstance] track:@"App Opened"];

    
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
    
    if (url)
    {
        NSString* launchURLString = [NSString stringWithFormat:@"%@",url];
        NSArray* urlComponents = [launchURLString componentsSeparatedByString:@"//"];
        if ([urlComponents count] ==2)
        {
            NSString* parametersString = [urlComponents objectAtIndex:1];
            
            NSArray* parameters = [parametersString componentsSeparatedByString:@"/"];
            if ([parameters count] == 3)
            {
                NSString* type = [parameters objectAtIndex:1];
                
                if ([type isEqualToString:@"apartment"])
                {
                    NSString* apartmentId = [parameters objectAtIndex:2];
                    SingleApartmentViewController* singleApartmentVC = [SingleApartmentViewController new];
                    singleApartmentVC.apartmentId = apartmentId;
                    _rootViewController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:singleApartmentVC];
                }
            }
            
        }
    }
    
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

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    if ([[Mixpanel sharedInstance]distinctId])
    {
        [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];
    }
    
    NSMutableArray* channels = [NSMutableArray new];
    [channels addObject:@"global" ];
    if (DEP.authenticatedUser)
    {
        [channels addObject:DEP.authenticatedUser.objectId];
    }
    currentInstallation.channels = channels;
    
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      
    }];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];

    [self setNotificationBadgeTo:[PFInstallation currentInstallation].badge];
    
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

-(void)setNotificationBadgeTo:(NSInteger)badgeNumber
{
    [(DashboardViewController*)self.rootViewController.leftPanel updateNotificationBadgeTo:badgeNumber];
    [self.rootViewController updateMenuButtonWithNumber:badgeNumber];

}

@end
