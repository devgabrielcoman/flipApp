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
@property (weak, nonatomic) IBOutlet UIButton *saySomethingBtn;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UIButton *adminBtn;
@property (weak, nonatomic) IBOutlet UIView *adminSeparatorView;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setProfileData];
}

- (void)setProfileData
{
    if(![lastUserId isEqualToString:DEP.authenticatedUser[@"facebookID"]])
    {
        _usernameLbl.text = DEP.authenticatedUser.username;
        [_locationLbl setTitle:DEP.authenticatedUser[@"location"] forState:UIControlStateNormal];
        
        _profileImgView.showActivityIndicator = YES;
        _profileImgView.image = nil;
        _profileImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
        
        lastUserId = DEP.authenticatedUser[@"facebookID"];
    }
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
    
    [_locationLbl setImage:[[UIImage imageNamed:@"map-marker-icon"] imageScaledToFitSize:CGSizeMake(12, 12)] forState:UIControlStateNormal];
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
                
                MyListingViewController* mylistingVC= [MyListingViewController new];
                mylistingVC.apartment=ap;
                ApartmentTableViewCell* topApartmentView = (ApartmentTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:nil options:nil] firstObject];
                topApartmentView.frame = CGRectMake(0,-44, wScr, hScr);
                [topApartmentView.apartmentTopView.displayMore setHidden:YES];

                [topApartmentView setApartment:ap.apartment withImages:ap.images andCurrentUsersStatus:YES];
                [topApartmentView setDelegate:mylistingVC];

                [mylistingVC.navigationController setNavigationBarHidden:YES];
                [self setTitle:@" "];
                mylistingVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
                [mylistingVC.view addSubview:topApartmentView];
                [(UIScrollView*)mylistingVC.view setContentSize:CGSizeMake(wScr, topApartmentView.frame.size.height-100)];
                [(UIScrollView*)mylistingVC.view setScrollEnabled:YES];
                [mylistingVC.view setBackgroundColor:[UIColor whiteColor]];
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:mylistingVC];
            }
            else
            {
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:[NoListingViewController new]];
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
    FavoritesTableViewController *favoritesVC = [FavoritesTableViewController new];
    
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:favoritesVC];
}

- (IBAction)openAdminMenu:(id)sender
{
    AdminViewController *adminVC = [[AdminViewController alloc] initWithNibName:@"AdminViewController" bundle:nil];
    
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:adminVC];
}

- (IBAction)showPreferences:(id)sender
{
    PreferencesViewController *preferencesVC = [PreferencesViewController new];
    self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:preferencesVC];
}

- (IBAction)sendEmail:(id)sender
{
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
    
    [self presentViewController:[AuthenticationViewController new] animated:YES completion:^{
        FeedViewController *feedVC = [FeedViewController new];
        self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:feedVC];
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
