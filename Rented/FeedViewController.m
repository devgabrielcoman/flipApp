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
#import "lastFeedCell.h"
#import "NothingCell.h"
#import "AuthenticationDoneViewController.h"
#import <AFNetworking/AFNetworking.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, ApartmentCellProtocol, MFMailComposeViewControllerDelegate,lastFeedCellDelegate, NothingCellDelegate>
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
    self.title = @" ";
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, wScr, hScr);
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApartmentCell"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    
    //changes applied on ios default pagination in order to be displayed as in design
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI_2);
    CGAffineTransform resize = CGAffineTransformMakeScale(1.4, 1.4);
    
    _pageControl.transform = CGAffineTransformConcat(rotate, resize);
    _pageControl.hidden = YES;
    
    expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
    
   //notifications is used to refresh apartments when arriving on feed after one user log out and another one authenticate
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFeed:)
                                                 name:@"ReloadFeedData" object:nil];
    
    [self reloadFeedData];
    
    self.tableView.allowsSelection = NO;

    
    indexForGetRequest = -1;
    
    if ([PFUser currentUser])
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
 
//                _pageControl.hidden = NO;
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
    [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    

    
    if(![DEP.api.userApi userIsAuthenticated])
    {
       
        UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        AuthenticationDoneViewController* doneVC = [AuthenticationDoneViewController new];
        UINavigationController* doneNavVC = [[UINavigationController alloc]initWithRootViewController:doneVC];

        [rootViewController presentViewController:doneNavVC animated:NO completion:nil];
        
        UINavigationController* authNavVC = [[UINavigationController alloc]initWithRootViewController:[AuthenticationViewController new]];
        [doneVC presentViewController:authNavVC animated:NO completion:nil];
        
        
        self.doneScreenHasBeenPresented =YES;
    }
    else
    {
        if(!self.doneScreenHasBeenPresented)
        {
            UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
            AuthenticationDoneViewController* doneVC = [AuthenticationDoneViewController new];
            UINavigationController* doneNavVC = [[UINavigationController alloc]initWithRootViewController:doneVC];
            [rootViewController presentViewController:doneNavVC animated:NO completion:nil];
            self.doneScreenHasBeenPresented =YES;

        }
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
        
        NothingCell* nothingCell = (NothingCell*)[[[NSBundle mainBundle] loadNibNamed:@"NothingCell" owner:self options:nil] firstObject];
        nothingCell.delegate = self;
        
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
        
        lastFeedCell* lastCell = (lastFeedCell*)[[[NSBundle mainBundle] loadNibNamed:@"lastFeedCell" owner:self options:nil] firstObject];
        lastCell.delegate = self;
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
#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex ==1)
    {
        
        Apartment *ap = _apartments[indexForGetRequest];
        
        ap.apartment[@"requested"] =[NSNumber numberWithInt:0];
        [ap.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        
        [[(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForGetRequest inSection:0] ] apartmentTopView].apartmentDetails updateFlipButtonStatus];
        
        [DEP.api.apartmentApi removeApartmentRequest:ap.apartment completion:^(BOOL succeeded) {
            
                    [[(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForGetRequest inSection:0] ] apartmentTopView].apartmentDetails updateFlipButtonStatus];
            
        } ];
        
    }

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

-(void)shareFlip
{
    [[Mixpanel sharedInstance] track:@"Pressed Share Flip"];
    
    NSString *textToShare = @" Check out Flip - it's a marketplace for lease breaks and lease takeovers ";

    NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/app/id970184178"];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://appstore.com/%@",@"Flip"]];
//    NSURL *url = [NSURL URLWithString:@"http://www.hiflip.com/"];
    
    NSArray *objectsToShare=@[url,textToShare];
    
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
    self.title = @" ";
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
    details.frame = CGRectMake(0,-44, wScr, 1318);
    details.controller = moreVC;
    Apartment *apartment = _apartments[index];
    details.apartmentImages = apartment.images;
    [(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]] apartmentTopView].apartmentDetails = details;
    
    //configure mutual friends label
    if ([apartment.apartment[@"hideFacebookProfile"] integerValue]==1)
    {
        [details.connectedThroughLbl setHidden:YES];
        [details.connectedThroughImageView setHidden:YES];
    }
    else
    {
        NSArray* mutualFriends=[GeneralUtils mutualFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
         details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
    }
    //user is never the owner in the browse screen
    details.currentUserIsOwner = NO;
    details.isFromFavorites = NO;
    details.apartmentIndex=index;
    [details setApartmentDetails:apartment.apartment];

    details.firstImageView = [(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:   [NSIndexPath indexPathForRow:index inSection:0]] apartmentTopView].apartmentImgView;
    details.apartmentImages = apartment.images;
    
    [details updateFlipButtonStatus];
    
    [self setTitle:@" "];
    moreVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [moreVC.view addSubview:details];
    [(UIScrollView*)moreVC.view setContentSize:CGSizeMake(wScr, details.frame.size.height -44) ];
    [(UIScrollView*)moreVC.view setScrollEnabled:YES];
    [moreVC.view setBackgroundColor:[UIColor whiteColor]];
    
    [[Mixpanel sharedInstance] track:@"Opened Listing" properties:@{@"apartment_id":apartment.apartment.objectId}];
    
    
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
                                 withNotification:YES
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
                                 withNotification:YES
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
    indexForGetRequest=index;
    
    [[Mixpanel sharedInstance] track:@"Pressed Get Listing" properties:@{@"apartment_id":ap.apartment.objectId}];
    
    //get all the requests a user has made
    [DEP.api.apartmentApi userHasRequestForApartment:ap.apartment completion:^(NSArray *objects, BOOL succeeded) {
        if(succeeded && objects.count == 1)
        {
            NSString* ownerName = ap.apartment[@"owner"][@"firstName"];
            NSString* apartmentType;
            if ([ap.apartment[@"bedrooms"] integerValue]==0)
            {
                apartmentType = @"Studio";
            }
            if ([ap.apartment[@"bedrooms"] integerValue]==1)
            {
                apartmentType = @"One Bedroom";
            }
            if ([ap.apartment[@"bedrooms"] integerValue]==2)
            {
                apartmentType = @"Two Bedrooms";
            }
            if ([ap.apartment[@"bedrooms"] integerValue]==3)
            {
                apartmentType = @"Three Bedrooms";
            }
            if ([ap.apartment[@"bedrooms"] integerValue]==4)
            {
                apartmentType = @"Four Bedrooms";
            }
            if ([ap.apartment[@"bedrooms"] integerValue]==5)
            {
                apartmentType = @"Five Bedrooms";
            }
            if (apartmentType == nil)
            {
                apartmentType = @"Apartment";
            }
            NSString* neighborhood = ap.apartment[@"neighborhood"];
            NSString* message;
            if ([ap.apartment[@"hideFacebookProfile"] integerValue]==1)
            {
                message= [NSString stringWithFormat:@"Are you sure you aren't interested in Annonymous User's %@ in %@ anymore?",apartmentType,neighborhood];
            }
            else
            {
                message= [NSString stringWithFormat:@"Are you sure you aren't interested in %@'s %@ in %@ anymore?",ownerName,apartmentType,neighborhood];
            }
            
            UIAlertView* unrequestAlertView =[[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [unrequestAlertView show];
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
                
                NSString *email;
                if ([ap.apartment[@"directContact"] integerValue]==0)
                {
                    email = @"hello@hiflip.com";
                }
                else
                {
                    email = owner.email;
                }

                
                if(!email || email.length==0)
                {
                    email = @"hello@hiflip.com";
                }
                    
                    
                    //email found
                    
                    //populate and show email composer
                    
                    MFMailComposeViewController *mail = [MFMailComposeViewController new];
                    
                    mail.mailComposeDelegate = self;
                    
                    NSString* apartmentType;
                    if ([ap.apartment[@"bedrooms"] integerValue]==0)
                    {
                        apartmentType = @"Studio";
                    }
                    if ([ap.apartment[@"bedrooms"] integerValue]==1)
                    {
                        apartmentType = @"One Bedroom";
                    }
                    if ([ap.apartment[@"bedrooms"] integerValue]==2)
                    {
                        apartmentType = @"Two Bedrooms";
                    }
                    if ([ap.apartment[@"bedrooms"] integerValue]==3)
                    {
                        apartmentType = @"Three Bedrooms";
                    }
                    if ([ap.apartment[@"bedrooms"] integerValue]==4)
                    {
                        apartmentType = @"Four Bedrooms";
                    }
                    if ([ap.apartment[@"bedrooms"] integerValue]==5)
                    {
                        apartmentType = @"Five Bedrooms";
                    }
                    if (apartmentType == nil)
                    {
                        apartmentType = @"Apartment";
                    }
                    NSString* neighborHood;
                    
                    if (ap.apartment[@"neighborhood"])
                    {
                        neighborHood = ap.apartment[@"neighborhood"];
                    }
                    else
                    {
                        if (ap.apartment[@"city"])
                        {
                            neighborHood = ap.apartment[@"city"];
                        }
                        else
                        {
                            neighborHood = @"";
                        }
                    }
                    
                    if ([ap.apartment[@"directContact"] integerValue]==0)
                    {
                        [mail setSubject:[NSString stringWithFormat:@"[Flip]%@ wants %@'s %@ in %@",DEP.authenticatedUser[@"firstName"], owner[@"firstName"],apartmentType, neighborHood]];
                    }
                    else
                    {
                        [mail setSubject:[NSString stringWithFormat:@"[Flip]Can I come see your %@ in %@",apartmentType,neighborHood]];
                    }
                    
                    
                    NSArray *toRecipients = [NSArray arrayWithObject:email];
                    NSArray *ccRecipients = @[];
                    NSArray *bccRecipients = @[];
                    
                    [mail setToRecipients:toRecipients];
                    [mail setCcRecipients:ccRecipients];
                    [mail setBccRecipients:bccRecipients];
                    
                    NSString *emailBody;
                    
                    if ([ap.apartment[@"directContact"] integerValue]==1)
                    {
                        emailBody = [NSString stringWithFormat: @"Hi %@,<br><br> I really like your apartment and I would like to come see it. Please let me know how I should arrange that.<br><br>Hope you're having a good day!<br><br>Best, %@",owner[@"firstName"],DEP.authenticatedUser[@"firstName"]];
                    }
                    else
                    {
                        emailBody = @"Hey, can you get this place for me?";
                    }
                    
                    [mail setMessageBody:emailBody isHTML:YES];
                    
                    [self presentViewController:mail animated:YES completion:NULL];
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
        
        ap.apartment[@"requested"] =[NSNumber numberWithInt:1];
        [ap.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        
        [[(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForGetRequest inSection:0] ] apartmentTopView].apartmentDetails updateFlipButtonStatus];
        
        [DEP.api.apartmentApi addApartmentToGetRequests:ap.apartment completion:^(BOOL succeeded) {
            if(succeeded)
            {
                [[[UIAlertView alloc] initWithTitle:@"Got it!" message:[NSString stringWithFormat:@"%@'s %@ in %@ will be saved to your likes!",ap.apartment[@"owner"][@"firstName"],[GeneralUtils roomsLongDescriptionForApartment:ap.apartment],ap.apartment[@"neighborhood"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                
                AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHostString]];
                NSDictionary *params = @{@"userId": [PFUser currentUser].objectId,
                                         @"apartmentId": ap.apartment.objectId};
                
                AFHTTPRequestOperation *op = [manager POST:@"/apartment/request" parameters:params  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                }];
                [op start];
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
        //change size using constraints
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
