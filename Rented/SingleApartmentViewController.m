//
//  MyPlaceViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "SingleApartmentViewController.h"
#import "ApartmentTableViewCell.h"
#import <MWPhotoBrowser.h>
#import "GalleryNavigationController.h"
#import "FullMapViewViewController.h"
#import "LocationUtils.h"
#import <UIAlertView+Blocks.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ApartmentDetailsOtherListingView.h"
#import "GeneralUtils.h"
#import "ConfirmationView.h"

@interface SingleApartmentViewController ()<MWPhotoBrowserDelegate, MFMailComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSIndexPath *expandedRow;
}

@property NSMutableArray *apartmentGalleryPhotos;

@end

@implementation SingleApartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"ApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApartmentCell"];
    
    expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
    
   

}

-(void)viewWillAppear:(BOOL)animated
{

    
    if (self.apartmentId && !self.apartment)
    {
        if([self.apartmentId containsString:@"?"])
        {
            self.apartmentId = [[self.apartmentId componentsSeparatedByString:@"?"] objectAtIndex:0];
        }
        
        [self.tableView setHidden:YES];
        [self.loadingLabel setHidden:NO];
        
        PFQuery* query = [PFQuery queryWithClassName:@"Apartment"];
        [query whereKey:@"objectId" equalTo:self.apartmentId];
        [query includeKey:@"owner"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            [DEP.api.apartmentApi completeListOfApartmentsForFeed:objects filterOnlyFromNetwork:NO completion:^(NSArray *apartments, BOOL succeeded) {
                
                self.apartment= [apartments firstObject];
                
                if ([[(PFUser*)self.apartment.apartment[@"owner"] objectId] isEqualToString:[DEP.authenticatedUser objectId]])
                {
                    self.userIsOwner =YES;
                }

                [self.tableView reloadData];
                [self.tableView setHidden:NO];
                [self.loadingLabel setHidden:YES];
                
            }];
            
        }];
    }
    else
    {
        [self.tableView setHidden:NO];
        [self.loadingLabel setHidden:YES];
        
        [self.tableView reloadData];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.apartment)
    {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return hScr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //actual apartment cell
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ApartmentCell" forIndexPath:indexPath];
    
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:self options:nil] firstObject];
    }
    
    
    [cell.layer setMasksToBounds:YES];
    Apartment *ap = _apartment;
    
    [cell setApartmentIndex:indexPath.row];
    
    //customise the apartment cell
    [cell setApartment:ap.apartment withImages:ap.images andCurrentUsersStatus:YES];
    [cell.apartmentTopView.myListingBar setHidden:YES];

    [cell setDelegate:self];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RTLog(@"Did select row at indexpath");
}

#pragma mark - Apartment cell protocol methods

- (void)displayGalleryForApartmentAtIndex:(NSInteger)index
{
    [self createGalleryPhotosArray];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.zoomPhotosToFill = YES;
    browser.alwaysShowControls = NO;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    //browser.extendedLayoutIncludesOpaqueBars = YES;
    
    [browser setCurrentPhotoIndex:0];
    
    GalleryNavigationController *galleryNavController = [[GalleryNavigationController alloc] initWithRootViewController:browser];

    [self.navigationController presentViewController:galleryNavController animated:YES completion:nil];
    //[self.navigationController pushViewController:browser animated:YES];
}

- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index
{
    FullMapViewViewController *fullMapView = [FullMapViewViewController new];
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    [locationPin setCoordinate:[LocationUtils locationFromPoint:_apartment.apartment[@"location"]]];
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
    Apartment *apartment = self.apartment;
    
    //configure mutual friends label
    NSArray* mutualFriends=[GeneralUtils mutualFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
    details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
    
    //user is never the owner in the browse screen
    details.currentUserIsOwner = NO;
    if (self.userIsOwner)
    {
        [details.getButton setHidden:YES];
        [details.connectedThroughImageView setHidden:YES];
        [details.connectedThroughLbl setHidden:YES];
    }
    else
    {
        [details.getButton setHidden:NO];
        [details.connectedThroughImageView setHidden:NO];
        [details.connectedThroughLbl setHidden:NO];
    }

    details.isFromFavorites = NO;
    details.apartmentIndex=index;
    [details setApartmentDetails:apartment.apartment];
    
    details.firstImageView = [(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:   [NSIndexPath indexPathForRow:index inSection:0]] apartmentTopView].apartmentImgView;
    
    [details updateFlipButtonStatus];
    
    [self setTitle:@" "];
    moreVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [moreVC.view addSubview:details];
    [(UIScrollView*)moreVC.view setContentSize:CGSizeMake(wScr, details.frame.size.height -64) ];
    [(UIScrollView*)moreVC.view setScrollEnabled:YES];
    [moreVC.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController pushViewController:moreVC animated:YES];
    
    
}

- (void)addToFravoritesApartmentFromIndex:(NSInteger)index
{
    
}

- (void)addToFravoritesApartment:(PFObject *)apartment
{
    
}

- (void)createGalleryPhotosArray
{
    if(!_apartmentGalleryPhotos)
        _apartmentGalleryPhotos = [NSMutableArray new];
    
    [_apartmentGalleryPhotos removeAllObjects];
    
    for (PFObject *imageObject in _apartment.images)
    {
        PFFile *imageFile = imageObject[@"image"];
        [_apartmentGalleryPhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageFile.url]]];
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

- (void)getApartmentAtIndex:(NSInteger)index
{
    [self sendGetMessage];
}

- (void)sendGetMessage
{
    
    Apartment *ap = self.apartment;
    if ([ap.apartment[@"requested"] integerValue] ==1)
    {
        return;
    }
    PFUser *owner = ap.apartment[@"owner"];
    
    //get all the requests a user has made
    [DEP.api.apartmentApi userHasRequestForApartment:ap.apartment completion:^(NSArray *objects, BOOL succeeded) {
        if(succeeded && objects.count == 1)
        {
            //if the user has already made a request
            //don't let him make another one

        }
        else
        {
            
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
                
                
                if(email.length)
                {
                    
                    
                    //email found
                    
                    //populate and show email composer
                    
                    MFMailComposeViewController *mail = [MFMailComposeViewController new];
                    
                    mail.mailComposeDelegate = self;
                    
                    NSString* apartmentType;
                    if ([ap.apartment[@"rooms"] containsObject:[NSNumber numberWithInt:0]])
                    {
                        apartmentType = @"Studio";
                    }
                    if ([ap.apartment[@"rooms"] containsObject:[NSNumber numberWithInt:1]])
                    {
                        apartmentType = @"One Bedroom";
                    }
                    if ([ap.apartment[@"rooms"] containsObject:[NSNumber numberWithInt:2]])
                    {
                        apartmentType = @"Two Bedrooms";
                    }
                    if ([ap.apartment[@"rooms"] containsObject:[NSNumber numberWithInt:3]])
                    {
                        apartmentType = @"Three Bedrooms";
                    }
                    if ([ap.apartment[@"rooms"] containsObject:[NSNumber numberWithInt:4]])
                    {
                        apartmentType = @"Three plus Bedrooms";
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
                    
                    [mail setSubject:[NSString stringWithFormat:@"%@'s %@ in %@",owner.username,apartmentType,neighborHood]];
                    
                    NSArray *toRecipients = [NSArray arrayWithObject:email];
                    NSArray *ccRecipients = @[];
                    NSArray *bccRecipients = @[];
                    
                    [mail setToRecipients:toRecipients];
                    [mail setCcRecipients:ccRecipients];
                    [mail setBccRecipients:bccRecipients];
                    
                    NSString *emailBody;
                    
                    if ([ap.apartment[@"directContact"] integerValue]==1)
                    {
                        emailBody = [NSString stringWithFormat: @"Hi %@,<br><br> I really like your apartment and I would like to come see it. Please let me know how I should arrange that.<br><br>Hope you're having a good day!<br><br>Best, %@",owner.username,DEP.authenticatedUser.username];
                    }
                    else
                    {
                        emailBody = @"Hey, can you get this place for me?";
                    }
                    
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
        Apartment *ap = _apartment;
        
        ap.apartment[@"requested"] =[NSNumber numberWithInt:1];
        [ap.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        
        [[(ApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ] apartmentTopView].apartmentDetails updateFlipButtonStatus];
        
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
#pragma mark - gesture recognizers



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
