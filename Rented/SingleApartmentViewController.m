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

@interface SingleApartmentViewController ()<MWPhotoBrowserDelegate, MFMailComposeViewControllerDelegate>
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    
    expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
    
    [self.tableView reloadData];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navSingleTap)];
    gestureRecognizer.numberOfTapsRequired = 1;
    CGRect frame = CGRectMake(self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44);
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.navigationController.navigationBar addSubview:navBarTapView];
    navBarTapView.backgroundColor = [UIColor clearColor];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
}

- (void)navSingleTap
{
    [self displayMoreInfoForApartmentAtIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath isEqual:expandedRow])
    {
        if(_isFromFavorites)
            return (hScr-statusBarHeight)+ApartmentDetailsOtherListingViewHeight+10+22+10;
        
        return (hScr-statusBarHeight)+ApartmentDetailsViewHeight+10;
    }
    
    return hScr-statusBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ApartmentCell" forIndexPath:indexPath];
    
    if(!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:self options:nil] firstObject];
    
    [cell setApartmentIndex:indexPath.row];
    if(!_isFromFavorites)
        [cell setApartment:_apartment.apartment withImages:_apartment.images andCurrentUsersStatus:YES];
    else
    {
        cell.isFromFavorites = _isFromFavorites;
        [cell setApartment:_apartment.apartment withImages:_apartment.images andCurrentUsersStatus:NO];
    }
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
    if(![[NSIndexPath indexPathForItem:index inSection:0] isEqual:expandedRow])
    {
        expandedRow = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[expandedRow] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:expandedRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
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
    [self sendGetApartmentMessageToUser:_apartment.apartment[@"owner"]];
}

- (void)sendGetApartmentMessageToUser:(PFUser *)user
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
        NSString *email = user[@"email"];
        if(email.length)
        {
            MFMailComposeViewController *mail = [MFMailComposeViewController new];
            
            mail.mailComposeDelegate = self;
            
            [mail setSubject:@"Flip apartment"];
            
            NSArray *toRecipients = [NSArray arrayWithObject:email];
            NSArray *ccRecipients = @[];
            NSArray *bccRecipients = @[];
            
            [mail setToRecipients:toRecipients];
            [mail setCcRecipients:ccRecipients];
            [mail setBccRecipients:bccRecipients];
            
            NSString *emailBody = [NSString stringWithFormat:@"Hi %@, <br> I really like your apartment and i would like to join....", user.username];
            [mail setMessageBody:emailBody isHTML:YES];
            
            [self presentViewController:mail animated:YES completion:NULL];
        }
        else
        {
            [UIAlertView showWithTitle:@""
                               message:@"You flip mate doesn't have an email address..."
                     cancelButtonTitle:@"Dismiss"
                     otherButtonTitles:nil
                              tapBlock:nil];
        }
        
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
