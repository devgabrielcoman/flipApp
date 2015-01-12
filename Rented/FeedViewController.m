//
//  HomeViewController.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "FeedViewController.h"
#import "AuthenticationViewController.h"
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

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, ApartmentCellProtocol, MFMailComposeViewControllerDelegate>
{
    NSIndexPath *expandedRow;
    int indexOfShownApartment;
}

@property NSMutableArray *apartmentGalleryPhotos;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApartmentCell"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    
    expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadFeed:)
                                                 name:@"ReloadFeedData" object:nil];
    
    [self reloadFeedData];
}

- (void)reloadFeed:(NSNotification*)notification
{
    [self reloadFeedData];
}

- (void)reloadFeedData
{
    if([DEP.api.userApi userIsAuthenticated])
    {
        [DEP.api.apartmentApi getFeedApartments:^(NSArray *apartments, BOOL succeeded) {
            if(succeeded)
            {
                self.apartments = apartments;
                indexOfShownApartment = 0;
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apartments.count && (indexOfShownApartment >= 0) ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([indexPath isEqual:expandedRow])
    {
        return (hScr-statusBarHeight)+ApartmentDetailsViewHeight;
    }
    
    return hScr-statusBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ApartmentCell" forIndexPath:indexPath];
    
    if(!cell)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentTableViewCell" owner:self options:nil] firstObject];
    
    Apartment *ap = _apartments[indexOfShownApartment];
    
    [cell setApartmentIndex:indexPath.row];
    [cell setApartment:ap.apartment withImages:ap.images andCurrentUsersStatus:NO];
    [cell setDelegate:self];
    
    if(![indexPath isEqual:expandedRow])
    {
        [cell hideApartmentDetails];
    }
    else
        [cell showApartmentDetails];
    
    return cell;
}

#pragma mark - Table view delegate

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
    //[self.navigationController pushViewController:browser animated:YES];
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
    if(![expandedRow isEqual:[NSIndexPath indexPathForRow:0 inSection:-1]] && ![[NSIndexPath indexPathForItem:index inSection:0] isEqual:expandedRow])
    {
        NSInteger prevIndex = expandedRow.row;
        expandedRow = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex inSection:0], expandedRow] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView scrollToRowAtIndexPath:expandedRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if(![[NSIndexPath indexPathForItem:index inSection:0] isEqual:expandedRow])
    {
        expandedRow = [NSIndexPath indexPathForItem:index inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[expandedRow] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView scrollToRowAtIndexPath:expandedRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        NSInteger prevIndex = expandedRow.row;
        expandedRow = [NSIndexPath indexPathForRow:0 inSection:-1];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:prevIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:prevIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
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
                                               [likeApartment removeFromParentView];
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

-(void)switchToNextApartmentFromIndex:(NSInteger)index{
    if (++indexOfShownApartment >= _apartments.count)
        indexOfShownApartment = -1;
    
    if (indexOfShownApartment != -1)
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    else
        [_tableView reloadData];
}

- (void)getApartmentAtIndex:(NSInteger)index
{
    Apartment *ap = _apartments[index];
    [self sendGetApartmentMessageToUser:ap.apartment[@"owner"]];
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
            
            NSString *emailBody = [NSString stringWithFormat:@"Hi %@, <br> I really like your apartment and i would to join....", user.username];
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

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
