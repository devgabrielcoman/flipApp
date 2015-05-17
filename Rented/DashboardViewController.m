//
//  DashboardViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "DashboardViewController.h"
#import <UIAlertView+Blocks.h>
#import "UIViewController+JASidePanels.h"
#import <JASidePanelController.h>
#import <AsyncImageView.h>
#import "UIImage+ProportionalFill.h"
#import "NoListingViewController.h"
#import "SingleApartmentViewController.h"
#import "RentedNavigationController.h"
#import "Apartment.h"
#import "FeedViewController.h"
#import "FavoritesTableViewController.h"
#import "PreferencesViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "AuthenticationViewController.h"
#import "AdminViewController.h"
#import "ApartmentTableViewCell.h"
#import "GeneralUtils.h"
#import "MyListingViewController.h"
#import "AppDelegate.h"
#import "TutorialPageView.h"
#import "LikesViewController.h"
#import "TermsOfServiceViewController.h"
#import "AuthenticationDoneViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface DashboardViewController ()<MFMailComposeViewControllerDelegate>
{
    NSString *lastUserId;
}

@property (weak, nonatomic) IBOutlet AsyncImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UIButton *myPlaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherPlacesBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationLbl;
@property (weak, nonatomic) IBOutlet UIButton *preferencesBtn;
@property (weak, nonatomic) IBOutlet UIButton *howItWorksButton;
@property (weak, nonatomic) IBOutlet UIButton *saySomethingBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UIButton *adminBtn;
@property (weak, nonatomic) IBOutlet UIView *adminSeparatorView;

@end

@implementation DashboardViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    lastUserId = @"";
    
    [self setVisualDetails];
    
    if(DEP.authenticatedUser && [DEP.authenticatedUser[@"isAdmin"] integerValue]==1)
    {
        [self showAdminOptions:YES];
    }
    else
    {
        [self showAdminOptions:NO];
    }
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    
//    self.locationManager.delegate = self;
//    if(IS_OS_8_OR_LATER){
//        NSUInteger code = [CLLocationManager authorizationStatus];
//        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
//            // choose one request according to your business.
//            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
//                [self.locationManager requestAlwaysAuthorization];
//            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
//                [self.locationManager  requestWhenInUseAuthorization];
//            } else {
//                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
//            }
//        }
//    }
//    [self.locationManager startUpdatingLocation];
    
    [self.notificationCircle.layer setCornerRadius:8];
    [self.notificationCircle setClipsToBounds:YES];
    
    PFInstallation* installation =[PFInstallation currentInstallation];
    if (installation)
    {
        [self updateNotificationBadgeTo:installation.badge];
    }
    else
    {
        [self updateNotificationBadgeTo:0];
    }
}

-(void)updateNotificationBadgeTo:(NSInteger)badgeNumber
{
    if (badgeNumber ==0)
    {
        [self.notificationCircle setHidden:YES];
        
    }
    else
    {
        [self.notificationCircle setHidden:NO];
        [self.notificationLabel setText:[NSString stringWithFormat:@"%d",badgeNumber]];
    }


}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    self.currentLocation = newLocation;
    
    
    [[CLGeocoder new] reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSString* city;
        NSString* country;
        NSString* state;
        
        
        CLPlacemark* placemark = (CLPlacemark*) [placemarks firstObject];
        

        if (placemark.locality)
        {
            city = placemark.locality;
        }
        if (placemark.country)
        {
            country = placemark.country;
        }
        if (placemark.country && [placemark.country isEqualToString:@"United States"])
        {
            state = [GeneralUtils stateAbbreviationForState: placemark.administrativeArea];
        }
        if(state)
        {
            DEP.authenticatedUser[@"location"]= [NSString stringWithFormat:@"%@, %@", city, state];
        }
        else if(country)
        {
            DEP.authenticatedUser[@"location"]= [NSString stringWithFormat:@"%@, %@", city, country];

        }
        else
        {
            DEP.authenticatedUser[@"location"]=city;
        }
        [DEP.authenticatedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            [_locationLbl setHidden:NO];
//            [_locationLbl setTitle:DEP.authenticatedUser[@"location"] forState:UIControlStateNormal];
        }];
        [self.locationManager stopUpdatingLocation];
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self setProfileData];
}

- (void)setProfileData
{
    if(![lastUserId isEqualToString:DEP.authenticatedUser[@"facebookID"]])
    {
        _usernameLbl.text = DEP.authenticatedUser[@"firstName"];
        [_usernameLbl setHidden:NO];
//        [_locationLbl setTitle:DEP.authenticatedUser[@"location"] forState:UIControlStateNormal];
//        [_locationLbl setHidden:NO];
        
        _profileImgView.showActivityIndicator = YES;
        _profileImgView.image = nil;
        _profileImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
        
        lastUserId = DEP.authenticatedUser[@"facebookID"];
    }
}

-(void)updateProfileData
{
    _usernameLbl.text = DEP.authenticatedUser[@"firstName"];
    [_usernameLbl setHidden:NO];
//    [_locationLbl setTitle:DEP.authenticatedUser[@"location"] forState:UIControlStateNormal];
//    [_locationLbl setHidden:NO];
    
    _profileImgView.showActivityIndicator = YES;
    _profileImgView.image = nil;
    _profileImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
    
    lastUserId = DEP.authenticatedUser[@"facebookID"];
}


- (void)setVisualDetails
{
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarView.backgroundColor = StatusBarBackgroundColor;
    [self.view addSubview:statusBarView];
    

    
    [_profileImgView removeFromSuperview];
    
    _profileImgView.layer.cornerRadius = _profileImgView.frame.size.width/2;
    _profileImgView.layer.masksToBounds = YES;
    
    CALayer *shadowContainerLayer = [CALayer layer];
    shadowContainerLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowContainerLayer.shadowRadius = 1.5f;
    shadowContainerLayer.shadowOffset = CGSizeMake(0.f, 1.f);
    shadowContainerLayer.shadowOpacity = 1.f;
    
    [shadowContainerLayer addSublayer:_profileImgView.layer];
    
    [self.view.layer addSublayer:shadowContainerLayer];
    
//    [_locationLbl setImage:[[UIImage imageNamed:@"map-marker-icon"] imageScaledToFitSize:CGSizeMake(12, 12)] forState:UIControlStateNormal];
}

-(void)showAdminOptions:(BOOL)visible
{
    [self.adminBtn setHidden:!visible];
    [self.adminSeparatorView setHidden:!visible];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Handlers

- (IBAction)openMyPlace:(id)sender
{
    
    [DEP.api.apartmentApi userApartment:^(PFObject *apartment, NSArray *images, BOOL succeeded) {
        
        if(succeeded)
        {
            if(apartment != nil && images !=nil)
            {

                
                Apartment *ap = [Apartment new];
                
                ap.apartment = apartment;
                ap.images = images;
                
//                MyListingViewController* mylistingVC= [MyListingViewController new];
//                mylistingVC.apartment=ap;
//                ApartmentTableViewCell* topApartmentView = (ApartmentTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:nil options:nil] firstObject];
//                topApartmentView.apartmentTopView.disableSwipeGestures=YES;
//                mylistingVC.apartmentCell=topApartmentView;
//                topApartmentView.frame = CGRectMake(0,-44, wScr, hScr);
//                [topApartmentView.apartmentTopView.displayMore setHidden:YES];
//
//                [topApartmentView setApartment:ap.apartment withImages:ap.images andCurrentUsersStatus:YES];
//                [topApartmentView setDelegate:mylistingVC];
//
//                ApartmentDetailsOtherListingView* details = (ApartmentDetailsOtherListingView*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:nil options:nil] firstObject];
//                [details setApartmentDetailsDelegate:mylistingVC];
//                
//                CGFloat descriptionSize=0;
//                
//
//                if([apartment[@"description"] isEqualToString:@" "])
//                {
//                    descriptionSize = 140.0f;
//                }
//                
//                //set frame to compensate for the invisible navigation bar, fix this once bar is removed
//                details.frame = CGRectMake(0,hScr-44-50-descriptionSize, wScr, 612-100);
//                [details setBackgroundColor:[UIColor clearColor]];
//                details.controller = mylistingVC;
//                
//                topApartmentView.apartmentTopView.apartmentDetails=details;
//                
//                [details.connectedThroughImageView setHidden:YES];
//                [details.connectedThroughLbl setHidden:YES];
//                [details.likeBtn setHidden:YES];
//                [details.shareBtn setHidden:YES];
//                
//                [details.getButton setFrame:CGRectMake(details.getButton.frame.origin.x, details.getButton.frame.origin.y, details.getButton.frame.size.width, details.getButton.frame.size.height)];
//                
//                details.firstImageView = topApartmentView.apartmentTopView.apartmentImgView;
//                
//                //user is never the owner in the browse screen
//                details.currentUserIsOwner = YES;
//                details.isFromFavorites = NO;
//
//                [details setApartmentDetails:ap.apartment];
//                
//                [details updateFlipButtonStatus];
//   
//                
//                [mylistingVC.navigationController setNavigationBarHidden:YES];
//                [self setTitle:@" "];
//                mylistingVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
//                [mylistingVC.view addSubview:details];
//                [mylistingVC.view addSubview:topApartmentView];
//                [(UIScrollView*)mylistingVC.view setContentSize:CGSizeMake(wScr, topApartmentView.frame.size.height+ details.frame.size.height-44-50-descriptionSize)];
//                [(UIScrollView*)mylistingVC.view setScrollEnabled:YES];
//                [mylistingVC.view setBackgroundColor:[UIColor whiteColor]];
                
                
                AddApartmentViewController* addApartmentVC = [[AddApartmentViewController alloc] initWithNibName:@"AddApartmentViewController" bundle:nil];
                [addApartmentVC setApartment:ap];
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:addApartmentVC];

            }
            else
            {
                AddApartmentViewController* addApartmentVC = [[AddApartmentViewController alloc] initWithNibName:@"AddApartmentViewController" bundle:nil];
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:addApartmentVC];
                
            }
        }
        else
            [UIAlertView showWithTitle:@""
                               message:@"An error occurred. Please try again"
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil
                              tapBlock:nil];
    }];
    
    [self.sidePanelController showCenterPanelAnimated:YES];
    
}

- (IBAction)openOtherPlaces:(id)sender
{
    FeedViewController *feedVC = [FeedViewController new];
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:feedVC];
    
}



- (IBAction)openMyLikes:(id)sender
{
    PFInstallation* installation = [PFInstallation currentInstallation];
    installation.badge = 0;
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
        [delegate setNotificationBadgeTo:0];
        
    }];

    
    FavoritesTableViewController *favoritesVC = [FavoritesTableViewController new];
    favoritesVC.tabBarItem.title=@"You Like";
    [favoritesVC.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont fontWithName:@"HelveticaNeue" size:17.0f], UITextAttributeFont,
                                                   [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1], UITextAttributeTextColor,
                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 15.0f)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    [favoritesVC.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont fontWithName:@"HelveticaNeue" size:17.0f], UITextAttributeFont,
                                                    [UIColor colorWithRed:55/255.0 green:153/255.0 blue:255/255.0 alpha:1], UITextAttributeTextColor,
                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 15.0f)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateSelected];
    LikesViewController* likesVC = [[LikesViewController alloc] initWithNibName:@"LikesViewController" bundle:nil];
    likesVC.tabBarItem.title=@"Likes You";
    [likesVC.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont fontWithName:@"HelveticaNeue" size:17.0f], UITextAttributeFont,
                                                    [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1], UITextAttributeTextColor,
                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 15.0f)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateNormal];
    [likesVC.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    [UIFont fontWithName:@"HelveticaNeue" size:17.0f], UITextAttributeFont,
                                                    [UIColor colorWithRed:55/255.0 green:153/255.0 blue:255/255.0 alpha:1], UITextAttributeTextColor,
                                                    [UIColor clearColor], UITextAttributeTextShadowColor,
                                                    [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 15.0f)], UITextAttributeTextShadowOffset,
                                                    nil] forState:UIControlStateSelected];
    
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    
    UITabBarController* tabBarController = [[UITabBarController alloc]init];
    

    
    [tabBarController setViewControllers:@[favoritesVC,likesVC]];
    
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:tabBarController];
    
    
}

- (IBAction)openAdminMenu:(id)sender
{
    AdminViewController *adminVC = [[AdminViewController alloc] initWithNibName:@"AdminViewController" bundle:nil];
    
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:adminVC];
}

- (IBAction)howItWorksButtonTapped:(id)sender
{
    [self setTitle:@" "];
//    TutorialPageView* page1 = [[TutorialPageView alloc] initWithNibName:@"TutorialPageView" bundle:nil];
//    page1.image = [UIImage imageNamed:@"1"];
//    page1.index = 1;
//    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:page1];

    TermsOfServiceViewController* tosVC = [[TermsOfServiceViewController alloc]init];
    tosVC.dashboardVC = self;
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:tosVC];
}

- (IBAction)showPreferences:(id)sender
{
    PreferencesViewController *preferencesVC = [PreferencesViewController new];
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:preferencesVC];
}

- (IBAction)sendEmail:(id)sender
{
    [[Mixpanel sharedInstance] track:@"Pressed Feedback"];

    
    if (![MFMailComposeViewController canSendMail])
    {
        [UIAlertView showWithTitle:@""
                           message:@"Cannot send emails from this device!"
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
    else
    {
        MFMailComposeViewController *mail = [MFMailComposeViewController new];
        
        mail.mailComposeDelegate = self;
        
        [mail setSubject:@"Feedback"];
        
        NSArray *toRecipients = [NSArray arrayWithObject:@"admin@hiflip.com"];
        NSArray *ccRecipients = @[];
        NSArray *bccRecipients = @[];
        
        [mail setToRecipients:toRecipients];
        [mail setCcRecipients:ccRecipients];
        [mail setBccRecipients:bccRecipients];
        
        NSString *emailBody = @"Hi, <br> I really like your application, although there are a few things to say..";
        [mail setMessageBody:emailBody isHTML:YES];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
}

- (IBAction)logoutUser:(id)sender
{
    [DEP.api.userApi logoutUser];
    DEP.authenticatedUser = nil;
    lastUserId=0;
    [self.usernameLbl setHidden:YES];
    
    
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    AuthenticationDoneViewController* doneVC = [AuthenticationDoneViewController new];
    UINavigationController* doneNavVC = [[UINavigationController alloc]initWithRootViewController:doneVC];
    
    [rootViewController presentViewController:doneNavVC animated:NO completion:nil];
    
    UINavigationController* authNavVC = [[UINavigationController alloc]initWithRootViewController:[AuthenticationViewController new]];
    [doneVC presentViewController:authNavVC animated:YES completion:^{
        FeedViewController *feedVC = [FeedViewController new];
        self.sidePanelController.centerPanel = [[RentedNavigationController alloc]
                                                initWithRootViewController:feedVC];
        feedVC.doneScreenHasBeenPresented = YES;
        [self.sidePanelController showLeftPanelAnimated:NO];
    }];

}

#pragma mark - MailComposer delegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(result == MFMailComposeResultFailed)
        [UIAlertView showWithTitle:@""
                           message:@"An error occurred, please try again."
                 cancelButtonTitle:@"Dismiss"
                 otherButtonTitles:nil
                          tapBlock:nil];
}

@end
