//
//  MyListingViewController.m
//  Rented
//
//  Created by Cristian Olteanu on 2/10/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "MyListingViewController.h"
#import "GalleryNavigationController.h"
#import "FullMapViewViewController.h"
#import "LocationUtils.h"
#import "ApartmentDetailsOtherListingView.h"
#import "GeneralUtils.h"
#import "AddApartmentViewController.h"
#import "AppDelegate.h"
#import "RentedPanelController.h"
#import "DashboardViewController.h"

@interface MyListingViewController ()


@end

@implementation MyListingViewController



#pragma mark - Apartment cell protocol methods

- (void)displayGalleryForApartmentAtIndex:(NSInteger)index
{
    [self createGalleryPhotosArray:index];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    
    [browser setCurrentPhotoIndex:0];
    
    GalleryNavigationController *galleryNavController = [[GalleryNavigationController alloc] initWithRootViewController:browser];
    
    [self.navigationController presentViewController:galleryNavController animated:YES completion:nil];
    //[self.navigationController pushViewController:browser animated:YES];
}

- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index
{
    FullMapViewViewController *fullMapView = [FullMapViewViewController new];
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    Apartment *ap = self.apartment;
    [locationPin setCoordinate:[LocationUtils locationFromPoint:ap.apartment[@"location"]]];
    fullMapView.locationPin = locationPin;
    
    [self.navigationController pushViewController:fullMapView animated:YES];
}

- (void)displayMoreInfoForApartmentAtIndex:(NSInteger)index
{
    UIViewController* moreVC= [UIViewController new];
    ApartmentDetailsOtherListingView* details = (ApartmentDetailsOtherListingView*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:nil options:nil] firstObject];
    [details setApartmentDetailsDelegate:self];
    details.frame = CGRectMake(0,-60, wScr, ApartmentDetailsOtherListingViewHeight);
    details.controller = moreVC;
    Apartment *apartment = self.apartment;
    
    NSArray* mutualFriends=[GeneralUtils mutableFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
    
    details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
    
    details.currentUserIsOwner = NO;
    details.isFromFavorites = NO;
    details.apartmentIndex=index;
    [details setApartmentDetails:apartment.apartment];
    
    [details.connectedThroughImageView setHidden:YES];
    [details.connectedThroughLbl setHidden:YES];
    
    [details updateFlipButtonStatus];
    
    [self setTitle:@" "];
    moreVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [moreVC.view addSubview:details];
    [(UIScrollView*)moreVC.view setContentSize:details.frame.size];
    [(UIScrollView*)moreVC.view setScrollEnabled:YES];
    [moreVC.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController pushViewController:moreVC animated:YES];
    
    
}


- (void)createGalleryPhotosArray:(NSInteger)index
{
    if(!self.apartmentGalleryPhotos)
        self.apartmentGalleryPhotos = [NSMutableArray new];
    
    [self.apartmentGalleryPhotos removeAllObjects];
    
    Apartment *ap = self.apartment;
    
    for (PFObject *imageObject in ap.images)
    {
        PFFile *imageFile = imageObject[@"image"];
        [_apartmentGalleryPhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageFile.url]]];
    }
}

-(void)editApartment
{
    AddApartmentViewController* editVC = [[AddApartmentViewController alloc] initWithNibName:@"AddApartmentViewController" bundle:nil];
    editVC.apartment=self.apartment;
    [self presentViewController:editVC animated:YES completion:^{
        
    }];
}

#pragma mark - MWPhotoBrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _apartmentGalleryPhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _apartmentGalleryPhotos.count)
        return [_apartmentGalleryPhotos objectAtIndex:index];
    
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addApartmentFinieshedWithChanges:(BOOL)changes
{
    if (changes)
    {
        AppDelegate* appDelegate= (AppDelegate*)[UIApplication sharedApplication].delegate;
        [(DashboardViewController*)[(RentedPanelController*)appDelegate.rootViewController leftPanel] openMyPlace:nil];
    }
}


@end
