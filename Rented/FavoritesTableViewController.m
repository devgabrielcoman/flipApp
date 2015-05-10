//
//  FavoritesTableViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "FavoriteApartmentTableViewCell.h"
#import "Apartment.h"
#import <UIAlertView+Blocks.h>
#import "SingleApartmentViewController.h"
#import "ApartmentDetailsOtherListingView.h"
#import "GeneralUtils.h"
#import "FullMapViewViewController.h"
#import "LocationUtils.h"


@interface FavoritesTableViewController ()

@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"FavoriteApartmentCell"];
    
    [DEP.api.apartmentApi getListOfFavoritesApartments:^(NSArray *favoriteApartments, BOOL succeeded) {
        if(succeeded)
        {
            _favoriteApartments = [[NSMutableArray alloc] initWithArray:favoriteApartments];
            [self.tableView reloadData];
        }
        else
        {
            [UIAlertView showWithTitle:@""
                               message:@"An error occurred while trying to get favorite apartments. Please try again."
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil
                              tapBlock:nil];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _favoriteApartments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteApartmentTableViewCell *cell = (FavoriteApartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"FavoriteApartmentCell" forIndexPath:indexPath];
    
    if(!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:self options:nil] firstObject];
    
    Apartment *ap = _favoriteApartments[indexPath.row];
    
    if(ap.images && ap.images.count > 0)
    {
        PFObject *firstImage = [ap.images firstObject];
        PFFile *imageFile = firstImage[@"image"];
        cell.apartmentImageView.crossfadeDuration =0.0;
        cell.apartmentImageView.showActivityIndicator = YES;
        cell.apartmentImageView.imageURL = [NSURL URLWithString:imageFile.url];
    }
    
    PFUser *owner = ap.apartment[@"owner"];
    NSString* type = [GeneralUtils roomsLongDescriptionForApartment:ap.apartment];
    NSString* location;
    if (ap.apartment[@"neighborhood"])
    {
        location = ap.apartment[@"neighborhood" ];
    }
    else
    {
        location = ap.apartment[@"city"];
    }
    if([ap.apartment[@"hideFacebookProfile"] integerValue]==1)
    {
        cell.apartmentDescriptionLbl.text = [NSString stringWithFormat:@"Annonymous User's %@ in %@",type,location];

    }
    else
    {
        cell.apartmentDescriptionLbl.text = [NSString stringWithFormat:@"%@'s %@ in %@", owner[@"firstName"],type,location];
    }
//    cell.locationLbl.text = ap.apartment[@"locationName"];
    
    cell.apartmentIndex = indexPath.row;
    cell.delegate = self;
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    Apartment *ap = _favoriteApartments[indexPath.row];
//    self.title = @" ";
//    SingleApartmentViewController *apartmentViewController = [SingleApartmentViewController new];
//    apartmentViewController.apartment = ap;
//    apartmentViewController.isFromFavorites = YES;
//    
//    [self.navigationController pushViewController:apartmentViewController animated:YES];
    
    //creates a default uiview and adds the apartment details view as a subview

    self.tabBarController.title = @" ";
    UIViewController* moreVC= [UIViewController new];
    self.details = (ApartmentDetailsOtherListingView*)[[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:nil options:nil] firstObject];
    [self.details setApartmentDetailsDelegate:self];
    
    //set frame to compensate for the invisible navigation bar, fix this once bar is removed
    self.details.frame = CGRectMake(0,-44, wScr, 1318);
    self.details.controller = moreVC;
    Apartment *apartment = _favoriteApartments[indexPath.row];
    self.details.apartmentImages = apartment.images;
    
    
    if ([apartment.apartment[@"hideFacebookProfile"] integerValue]==1)
    {
        [self.details.connectedThroughLbl setHidden:YES];
        [self.details.connectedThroughImageView setHidden:YES];
    }
    else
    {
        //configure mutual friends label
        NSArray* mutualFriends=[GeneralUtils mutualFriendsInArray1:apartment.apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
        self.details.connectedThroughLbl.text = [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
    }

    
    //user is never the owner in the browse screen
    self.details.currentUserIsOwner = NO;
    self.details.isFromFavorites = NO;
    self.details.apartmentIndex=indexPath.row;
    [self.details setApartmentDetails:apartment.apartment];
    
    self.details.firstImageView = [(FavoriteApartmentTableViewCell*)[self.tableView cellForRowAtIndexPath:   [NSIndexPath indexPathForRow:indexPath.row inSection:0]] apartmentImageView];
    self.details.apartmentImages = apartment.images;
    
    [self.details updateFlipButtonStatus];
    
    moreVC.view=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [moreVC.view addSubview:self.details];
    [(UIScrollView*)moreVC.view setContentSize:CGSizeMake(wScr, self.details.frame.size.height -44) ];
    [(UIScrollView*)moreVC.view setScrollEnabled:YES];
    [moreVC.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController pushViewController:moreVC animated:YES];
    


}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self removeFromApartmentFromFavorites:indexPath.row];
    }
}

- (void)removeFromApartmentFromFavorites:(NSInteger)apartmentIndex
{
    Apartment *ap = _favoriteApartments[apartmentIndex];
    
    [_favoriteApartments removeObject:ap];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:apartmentIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    
    [DEP.api.apartmentApi removeApartmentFromFavorites:ap.apartment completion:^(BOOL succeeded) {
        if(!succeeded)
            RTLog(@"favorite apartment not deleted: %i", succeeded);
        
        [self.tableView reloadData];
    }];
}
-(void)getApartmentAtIndex:(NSInteger)index
{
    [self sendGetMessageForApartmentAtIndex:index];
}

- (void)sendGetMessageForApartmentAtIndex:(NSInteger)index
{
    
    Apartment *ap = _favoriteApartments[index];
    PFUser *owner = ap.apartment[@"owner"];
    self.indexForGetRequest=index;
    
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex ==1)
    {
        
        Apartment *ap = _favoriteApartments[_indexForGetRequest];
        
        ap.apartment[@"requested"] =[NSNumber numberWithInt:0];
        [ap.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        
        [self.details updateFlipButtonStatus];

        
        [DEP.api.apartmentApi removeApartmentRequest:ap.apartment completion:^(BOOL succeeded) {
            
            [self.details updateFlipButtonStatus];
            
        } ];
        
    }
    
}

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
        
        Apartment *ap = _favoriteApartments[self.indexForGetRequest];
        
        ap.apartment[@"requested"] =[NSNumber numberWithInt:1];
        [ap.apartment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        

        
        [DEP.api.apartmentApi addApartmentToGetRequests:ap.apartment completion:^(BOOL succeeded) {
            if(succeeded)
            {
                [[[UIAlertView alloc] initWithTitle:@"Got it!" message:[NSString stringWithFormat:@"%@'s %@ in %@ will be saved to your likes!",ap.apartment[@"owner"][@"firstName"],[GeneralUtils roomsLongDescriptionForApartment:ap.apartment],ap.apartment[@"neighborhood"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [self.details updateFlipButtonStatus];

            }
        }];
    }
}

- (void)displayFullMapViewForApartmentAtIndex:(NSInteger)index
{
    self.tabBarController.title = @" ";
    FullMapViewViewController *fullMapView = [FullMapViewViewController new];
    MKPointAnnotation *locationPin = [MKPointAnnotation new];
    Apartment *ap = _favoriteApartments[self.indexForGetRequest];
    [locationPin setCoordinate:[LocationUtils locationFromPoint:ap.apartment[@"location"]]];
    fullMapView.locationPin = locationPin;
    
    [self.navigationController pushViewController:fullMapView animated:YES];
}
@end
