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
#import "MyPlaceViewController.h"
#import "RentedNavigationController.h"
#import "Apartment.h"
#import "FeedViewController.h"

@interface DashboardViewController ()

@property (weak, nonatomic) IBOutlet AsyncImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UIButton *myPlaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *otherPlacesBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationLbl;
@property (weak, nonatomic) IBOutlet UIButton *preferencesBtn;
@property (weak, nonatomic) IBOutlet UIButton *saySomethingBtn;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setVisualDetails];
    [self setProfileData];
}

- (void)setProfileData
{
    _usernameLbl.text = DEP.authenticatedUser.username;
    [_locationLbl setTitle:DEP.authenticatedUser[@"location"] forState:UIControlStateNormal];
    
    _profileImgView.showActivityIndicator = YES;
    _profileImgView.imageURL = [NSURL URLWithString:DEP.authenticatedUser[@"profilePictureUrl"]];
}

- (void)setVisualDetails
{
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarView.backgroundColor = StatusBarBackgroundColor;
    [self.view addSubview:statusBarView];
    
    _myPlaceBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    _otherPlacesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    _likesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    
    _preferencesBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _saySomethingBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
    _usernameLbl.font = [UIFont fontWithName:@"GothamRounded-Bold" size:13.0];
    _locationLbl.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:10.0];
    
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
            if(apartment)
            {
                MyPlaceViewController *myPlace = [MyPlaceViewController new];
                Apartment *ap = [Apartment new];
                
                ap.apartment = apartment;
                ap.images = images;
                
                myPlace.apartment = ap;
                
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:myPlace];
            }
            else
                self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:[NoListingViewController new]];
        }
        else
            [UIAlertView showWithTitle:@""
                               message:@"An error occurred. Please try again"
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil
                              tapBlock:nil];
    }];
}

- (IBAction)openOtherPlaces:(id)sender
{
    [DEP.api.apartmentApi getFeedApartments:^(NSArray *apartments, BOOL succeeded) {
        if(succeeded)
        {
            FeedViewController *feedVC = [FeedViewController new];
            feedVC.apartments = apartments;
            
            self.sidePanelController.centerPanel = [[RentedNavigationController alloc] initWithRootViewController:feedVC];
        }
        else
            [UIAlertView showWithTitle:@""
                               message:@"An error occurred. Please try again"
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil
                              tapBlock:nil];
    }];
    
}

- (IBAction)openMyLikes:(id)sender {
}

- (IBAction)showPreferences:(id)sender {
}

- (IBAction)sendEmail:(id)sender {
}



@end
