//
//  HomeViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "FeedViewController.h"
#import "AuthenticationViewController.h"
#import "TutorialViewController.h"
#import "ApartmentTableViewCell.h"
#import <MWPhotoBrowser.h>
#import "GalleryNavigationController.h"
#import "FullMapViewViewController.h"
#import "LocationUtils.h"
#import "Apartment.h"
#import "UITableView+AnimationControl.h"
#import "LikedApartment.h"
#import <UIAlertView+Blocks.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ContactViewController.h"
#import "UIView+MLScreenshot.h"
#import "GeneralUtils.h"
#import "ConfirmationView.h"
#import "ApartmentDetailsOtherListingView.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, ApartmentCellProtocol, MFMailComposeViewControllerDelegate>
{
    NSIndexPath *expandedRow;
    int indexOfShownApartment;
    
    UILabel *lbNoMoreApartments;
    NSInteger indexForGetRequest;
}

@property NSMutableArray *apartmentGalleryPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, wScr, hScr);
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApartmentCell"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    
    //position pageControl
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI_2);
    CGAffineTransform resize = CGAffineTransformMakeScale(1.4, 1.4);
    
    _pageControl.transform = CGAffineTransformConcat(rotate, resize);
    _pageControl.hidden = YES;
    
    expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFeed:)
                                                 name:@"ReloadFeedData" object:nil];
    
    [self reloadFeedData];
    
    self.tableView.allowsSelection = NO;

    
    indexForGetRequest = -1;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)reloadFeed:(NSNotification*)notification
{
    [self reloadFeedData];
}

- (void)reloadFeedData
{
    if([DEP.api.userApi userIsAuthenticated])
    {
        [DEP.api.apartmentApi getListOfFavoritesApartments:^(NSArray *favoriteApartments, BOOL succeeded) {
            DEP.favorites = [NSMutableArray new];
            for (Apartment* apart in favoriteApartments)
            {
                [DEP.favorites addObject:apart.apartment.objectId];
                NSLog(@"%@",apart.apartment.objectId);
            }
        }];
        
        [DEP.api.apartmentApi getFeedApartments:^(NSArray *apartments, BOOL succeeded) {
            if(succeeded)
            {
                [self.tableView setHidden:NO];
                [self.loadingLabel setHidden:YES];
                self.apartments = apartments;
                indexOfShownApartment = 0;
 
                _pageControl.hidden = NO;
                _pageControl.numberOfPages = apartments.count;
        
                [self layoutPageControl];
                
                [self.tableView reloadData];
                
            }
        }];
    }
    else
    {
        self.apartments = @[];
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if(![DEP.api.userApi userIsAuthenticated])
    {
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [rootViewController presentViewController:[AuthenticationViewController new] animated:NO completion:nil];
    }
    else
    {

    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.apartments.count==0)
    {
        return 1;
    }
    
    return self.apartments.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if(self.apartments.count==0)
    {
        return hScr-statusBarHeight;
    }
    if(indexPath.row == self.apartments.count)
    {
        return hScr-statusBarHeight;
    }
    else
    {
        return self.view.frame.size.height ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.apartments.count==0)
    {
        //no apartments in array
        //search is too restrictive
        
        UITableViewCell* nothingCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nothingCell"];
        nothingCell.textLabel.text = @"Looks like we don't have anything to show you today. Try broadening your search!";
        nothingCell.textLabel.numberOfLines=3;
        [nothingCell.textLabel setFont:[UIFont fontWithName:@"GothamRounded-Light" size:13.0]];
        [nothingCell.textLabel setTextColor:[UIColor darkGrayColor]];
        [nothingCell.textLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self.tableView setScrollEnabled:NO];
        
        return nothingCell;
    }
    else
    {
        //at least one apartment is in the array
        
        [self.tableView setScrollEnabled:YES];
    }
    
    if(indexPath.row == self.apartments.count)
    {
        //the "that's all for now" table cell
        
        UITableViewCell* lastCell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"lastFeedCell" owner:self options:nil] firstObject];
        
        return lastCell;
    }
    
    
    //actual apartment cell
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ApartmentCell" forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:self options:nil] firstObject];
    }

    
    [cell.layer setMasksToBounds:YES];
    Apartment *ap = _apartments[indexPath.row];
    
    [cell setApartmentIndex:indexPath.row];
    
    //customise the apartment cell
    [cell setApartment:ap.apartment withImages:ap.images andCurrentUsersStatus:NO];
    [cell setDelegate:self];
    
 
    
    return cell;
}

#pragma mark - Table view delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([[self.tableView indexPathsForVisibleRows] count])
    {
        [self.pageControl setCurrentPage: [(NSIndexPath*)[[self.tableView indexPathsForVisibleRows] objectAtIndex:0] row]];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RTLog(@"Did select row at indexpath");
}

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
}

- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index
{
    FullMapViewViewController *fullMapView = [FullMapViewViewController new];
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    Apartment *ap = _apartments[index];
    [locationPin setCoordinate:[LocationUtils locationFromPoint:ap.apartment[@"location"]]];
    fullMapView.locationPin = locationPin;
    
    [self.navigationController pushViewController:fullMapView animated:YES];
}

- (void)displayMoreInfoForApartmentAtIndex:(NSInteger)index
{
    
    //creates a default uiview and adds the apartment details view as a subview
    
    UIViewController* moreVC= [UIViewController new];
    ApartmentDetailsOtherListingView* details = (ApartmentDetailsOtherListingView*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:nil options:nil] firstObject];
    [details setApartmentDetailsDelegate:self];
    
    //set frame to compensate for the invisible navigation bar, fix this once bar is removed
    details.frame = CGRectMake(0,-64, wScr, ApartmentDetailsOtherListingViewHeight);
    details.controller = moreVC;
    Apartment *apartment = _apartments[index];

    //configure mutual friends label
    NSArray* mutualFriends=[GeneralUtils mutableFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
     details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];

    //user is never the owner in the browse screen
    details.currentUserIsOwner = NO;
    details.isFromFavorites = NO;
    details.apartmentIndex=index;
    [details setApartmentDetails:apartment.apartment];
    
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
    if(!_apartmentGalleryPhotos)
        _apartmentGalleryPhotos = [NSMutableArray new];
    
    [_apartmentGalleryPhotos removeAllObjects];
    
    Apartment *ap = _apartments[index];
    
    for (PFObject *imageObject in ap.images)
    {
        PFFile *imageFile = imageObject[@"image"];
        [_apartmentGalleryPhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageFile.url]]];
    }
}


#pragma mark - Appartament delegate

- (void)addToFravoritesApartmentFromIndex:(NSInteger)index
{
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    UIImage *heartImage = [UIImage imageNamed:@"heart-image"];
    LikedApartment *likeApartment = [[LikedApartment alloc] initWithSize:heartImage.size inParentFrame:cell.apartmentTopView.apartmentImgView.frame];
    likeApartment.image = heartImage;
    
    [likeApartment displayInParentView:cell.apartmentTopView.apartmentImgView];
    
    Apartment *ap = _apartments[index];
    [DEP.api.apartmentApi addApartmentToFavorites:ap.apartment
                                       completion:^(BOOL succeeded) {
                                           if(succeeded)
                                               [likeApartment removeFromParentView:^(BOOL finished) {
                                                   [self switchToNextApartmentFromIndex:indexOfShownApartment];
                                               }];
                                           else
                                           {
                                               [UIAlertView showWithTitle:@""
                                                                  message:@"An error occurred while trying to add this apartment to favorites. Please try again."
                                                        cancelButtonTitle:@"Dismiss"
                                                        otherButtonTitles:nil
                                                                 tapBlock:nil];
                                           }
                                       }];
}

- (void)addToFravoritesApartment:(PFObject *)apartment
{
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    UIImage *heartImage = [UIImage imageNamed:@"heart-image"];
    LikedApartment *likeApartment = [[LikedApartment alloc] initWithSize:heartImage.size inParentFrame:cell.apartmentTopView.apartmentImgView.frame];
    likeApartment.image = heartImage;
    
    [likeApartment displayInParentView:cell.apartmentTopView.apartmentImgView];
    
    [DEP.api.apartmentApi addApartmentToFavorites:apartment
                                       completion:^(BOOL succeeded) {
                                           if(succeeded)
                                           {
                                               [likeApartment removeFromParentView:^(BOOL finished) {
                                                   [self switchToNextApartmentFromIndex:indexOfShownApartment];
                                               }];
                                           }
                                           else
                                           {
                                               [UIAlertView showWithTitle:@""
                                                                  message:@"An error occurred while trying to add this apartment to favorites. Please try again."
                                                        cancelButtonTitle:@"Dismiss"
                                                        otherButtonTitles:nil
                                                                 tapBlock:nil];
                                           }
                                       }];
}



- (void)getApartmentAtIndex:(NSInteger)index
{
    //user pressed the get button in the details screen for an apartment
    [self sendGetMessageForApartmentAtIndex:index];
}

- (void)sendGetMessageForApartmentAtIndex:(NSInteger)index
{

    Apartment *ap = _apartments[index];
    PFUser *owner = ap.apartment[@"owner"];
    
    
    //get all the requests a user has made
    [DEP.api.apartmentApi userHasRequestForApartment:ap.apartment completion:^(NSArray *objects, BOOL succeeded) {
        if(succeeded && objects.count == 1)
        {
            //if the user has already made a request
            //don't let him make another one
            
            ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            ContactViewController *contactVC = [[ContactViewController alloc] init];
            
            contactVC.apartmentSnapshot = [cell.apartmentTopView screenshot];
            contactVC.message = [NSString stringWithFormat:@"Hold tight, %@! Your flipmate is going to work things out between you and %@'s %@.", DEP.authenticatedUser[@"username"], owner[@"username"], [GeneralUtils roomsDescriptionForApartment:ap.apartment]];
            
            contactVC.apartment = ap.apartment;
            
            [self.navigationController presentViewController:contactVC animated:YES completion:nil];
        }
        else
        {
            //if the query failed of the user doesn't have an active request
            
            //check if the device can send an email
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
                //check it the apartment owner has an email address
                
                NSString *email = owner[@"email"];
                if(email.length)
                {
                    //email found
                    //populate and show email composer
                    
                    MFMailComposeViewController *mail = [MFMailComposeViewController new];
                    
                    mail.mailComposeDelegate = self;
                    
                    [mail setSubject:@"Flip apartment"];
                    
                    NSArray *toRecipients = [NSArray arrayWithObject:email];
                    NSArray *ccRecipients = @[];
                    NSArray *bccRecipients = @[];
                    
                    [mail setToRecipients:toRecipients];
                    [mail setCcRecipients:ccRecipients];
                    [mail setBccRecipients:bccRecipients];
                    
                    NSString *emailBody = [NSString stringWithFormat:@"Hi %@, <br> I really like your apartment and i would like to join....", owner.username];
                    [mail setMessageBody:emailBody isHTML:YES];
                    
                    [self presentViewController:mail animated:YES completion:NULL];
                }
                else
                {
                    //user doesn't have an email address
                    
                    [UIAlertView showWithTitle:@""
                                       message:@"You flip mate doesn't have an email address..."
                             cancelButtonTitle:@"Dismiss"
                             otherButtonTitles:nil
                                      tapBlock:nil];
                }
                
            }
        }
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
    else if(result == MFMailComposeResultSent)
    {
        Apartment *ap = _apartments[indexForGetRequest];
        
        [DEP.api.apartmentApi addApartmentToGetRequests:ap.apartment completion:^(BOOL succeeded) {
            if(succeeded)
            {
                ConfirmationView *confirmationView = [[[NSBundle mainBundle] loadNibNamed:@"ConfirmationView" owner:self options:nil] firstObject];
                confirmationView.center = self.view.center;
                confirmationView.alpha = 0.0;
                
                [self.view addSubview:confirmationView];
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     confirmationView.alpha = 1.0;
                                 }];
            }
        }];
    }
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

#pragma mark - shitty methods



-(void)layoutPageControl
{
    CGRect frame = _pageControl.bounds;
    frame.size.height = 16;
    frame.size.width = 8 * [_apartments count] + 8 * ([_apartments count] -1) + 8;

    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //modific size-ul prin constrainturi
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:frame.size.height]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:frame.size.width]];
        //constraint pentru right-margin 
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl
                                                              attribute:NSLayoutAttributeRightMargin
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:frame.size.width/2 - frame.size.height]];
        
    }
    else
    {
        [_pageControl removeFromSuperview];
        [_pageControl removeConstraints:_pageControl.constraints];
        
        frame.size.width -= 50;
        frame.origin.x = wScr - frame.size.width;
        frame.origin.y = self.view.center.y;
        _pageControl.frame = frame;
        
        _pageControl.backgroundColor = [UIColor clearColor];
        
        CGRect backgroundViewFrame = _pageControl.frame;
        backgroundViewFrame.size.height = _apartments.count * (backgroundViewFrame.size.height+6);
        backgroundViewFrame.origin.y = _pageControl.center.y - backgroundViewFrame.size.height/2;
        
        UIView *backgroundPaginationView = [[UIView alloc] initWithFrame:backgroundViewFrame];
        backgroundPaginationView.backgroundColor = [UIColor lightGrayColor];
        backgroundPaginationView.alpha = 0.8;
        
        //RTLog(@"sad panda -  %@", NSStringFromCGRect(backgroundPaginationView.frame));
        
        [self.view addSubview:backgroundPaginationView];
        [self.view addSubview:_pageControl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
