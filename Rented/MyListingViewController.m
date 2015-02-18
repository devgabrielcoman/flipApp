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
#import "LikesViewController.h"

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
    
    NSArray* mutualFriends=[GeneralUtils mutualFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
    
    details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
    
    details.currentUserIsOwner = NO;
    details.isFromFavorites = NO;
    details.apartmentIndex=index;
    [details setApartmentDetails:apartment.apartment];
    
    [details.connectedThroughImageView setHidden:YES];
    [details.connectedThroughLbl setHidden:YES];
    details.firstImageView=self.apartmentCell.apartmentTopView.apartmentImgView;
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
    editVC.image = self.apartmentCell.apartmentTopView.apartmentImgView.image;
    editVC.delegate = self;
    self.title = @" ";
    [self.navigationController pushViewController:editVC animated:YES];
}

-(void)showLikes
{
    if (self.likesArray && self.likesArray.count)
    {
        self.title =@" ";
    
        LikesViewController* likesVC = [[LikesViewController alloc] initWithNibName:@"LikesViewController" bundle:nil];
        [likesVC setFavoritesArray:self.likesArray];
        [self.navigationController pushViewController:likesVC animated:YES];
            
    }
}

-(void)shareApartment
{
    
    NSString *textToShare = @"Check out this apartment!";
    if ([textToShare isEqualToString:@""])
    {
        textToShare =@" ";
    }
    
    NSURL *url = [NSURL URLWithString:_apartment.apartment[@"shareUrl"]];
    UIImage* image = self.apartmentCell.apartmentTopView.apartmentImgView.image;
    
    NSArray *objectsToShare;
    
    if (image)
    {
        objectsToShare = @[textToShare, url,image];
    }
    else
    {
        objectsToShare = @[textToShare, url,image];
        
    }
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
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


- (void) navBarTapped: (UITapGestureRecognizer *)recognizer
{
    CGPoint tapPosition = [recognizer locationInView:self.navigationController.navigationBar];
    [[self.apartmentCell  apartmentTopView] tappedAtPosition:tapPosition];
}
-(void)viewWillAppear:(BOOL)animated
{
//    if([self.navigationController.viewControllers count]==1)
//    {
//        UITapGestureRecognizer* navBarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTapped:)];
//        [self.navigationController.navigationBar addGestureRecognizer:navBarTap];
//    }
    
    PFQuery* query = [PFQuery queryWithClassName:@"Favorites"];
    [query whereKey:@"apartment" equalTo:self.apartment.apartment];
    [query includeKey:@"user"];
    [query orderByDescending:@"timestamp"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count]==1)
        {
            [self.apartmentCell.apartmentTopView.likesButton setTitle:[NSString stringWithFormat:@"%u like",[objects count]] forState:UIControlStateNormal];
        }
        else
        {
            [self.apartmentCell.apartmentTopView.likesButton setTitle:[NSString stringWithFormat:@"%u likes",[objects count]] forState:UIControlStateNormal];
        }
        [self.apartmentCell.apartmentTopView.likesButton setHidden:NO];

        self.likesArray = objects;
        
    }];
        
}
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
