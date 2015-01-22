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
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, wScr, hScr);
    
    lbNoMoreApartments = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 260,100)];
    [lbNoMoreApartments setText:@"That's all we've got for today"];
    [lbNoMoreApartments setNumberOfLines:0];
    [lbNoMoreApartments setTextAlignment:NSTextAlignmentCenter];
    [lbNoMoreApartments sizeToFit];
    lbNoMoreApartments.center = self.view.center;
    [self.view addSubview:lbNoMoreApartments];
    
    lbNoMoreApartments.hidden = YES;
    
    lbNoMoreApartments.font = [UIFont fontWithName:@"GothamRounded-Bold" size:15.0];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"ApartmentCell"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    
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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navSingleTap)];
    gestureRecognizer.numberOfTapsRequired = 1;
    CGRect frame = CGRectMake(self.view.frame.size.width/4, 0, self.view.frame.size.width/2, 44);
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.navigationController.navigationBar addSubview:navBarTapView];
    navBarTapView.backgroundColor = [UIColor clearColor];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
    
    indexForGetRequest = -1;
}

- (void)navSingleTap
{
    [self displayMoreInfoForApartmentAtIndex:0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)reloadFeed:(NSNotification*)notification
{
    NSNumber *didShowTutorial = [[NSUserDefaults standardUserDefaults] objectForKey:@"didShowTutorial"];
    
    if (didShowTutorial == nil){
        TutorialViewController *tutorial = [[TutorialViewController alloc] initWithNibName:nil bundle:nil];
        
        [self presentViewController:tutorial animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:@YES] forKey:@"didShowTutorial"];
        }];
    }
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
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int rows = self.apartments.count && (indexOfShownApartment >= 0) ? 1 : 0;
    
    // afisare label doar cand nu sunt celule afisate si exista totusi apartamente - aka am dat scroll pana la capat => nu vad labelul la 'loading';
    lbNoMoreApartments.hidden = !(!rows && self.apartments.count > 0);

    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath isEqual:expandedRow])
    {
        CGFloat extra = 22;
        
        return (hScr-statusBarHeight)+ApartmentDetailsOtherListingViewHeight+10+extra+10;
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

-(void)switchToNextApartmentFromIndex:(NSInteger)index
{
    if (++indexOfShownApartment >= _apartments.count)
        indexOfShownApartment = -1;
    
//    if (indexOfShownApartment != -1)
//        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    else
//        [_tableView reloadData];
    
//    [_tableView reloadData];
    
    if (indexOfShownApartment != -1){
        //[_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView reloadData];
        _pageControl.currentPage = indexOfShownApartment;
    }
    else{
        [_tableView reloadData];
        _pageControl.hidden = YES;
    }
}

- (void)getApartmentAtIndex:(NSInteger)index
{
//    Apartment *ap = _apartments[index];
//    [self sendGetApartmentMessageToUser:ap.apartment[@"owner"]];
    [self sendGetMessageForApartmentAtIndex:index];
}

- (void)sendGetMessageForApartmentAtIndex:(NSInteger)index
{
    indexForGetRequest = indexOfShownApartment;
    Apartment *ap = _apartments[indexForGetRequest];
    PFUser *owner = ap.apartment[@"owner"];
    
    [DEP.api.apartmentApi userHasRequestForApartment:ap.apartment completion:^(NSArray *objects, BOOL succeeded) {
        if(succeeded && objects.count == 1)
        {
            ApartmentTableViewCell *cell = (ApartmentTableViewCell *) [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            ContactViewController *contactVC = [[ContactViewController alloc] init];
            
            contactVC.apartmentSnapshot = [cell.apartmentTopView screenshot];
            contactVC.message = [NSString stringWithFormat:@"Hold tight, %@! Your flipmate is going to work things out between you and %@'s %@.", DEP.authenticatedUser[@"username"], owner[@"username"], [GeneralUtils roomsDescriptionForApartment:ap.apartment]];
            
            contactVC.apartment = ap.apartment;
            
            [self.navigationController presentViewController:contactVC animated:YES completion:nil];
        }
        else
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
                NSString *email = owner[@"email"];
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
                    
                    NSString *emailBody = [NSString stringWithFormat:@"Hi %@, <br> I really like your apartment and i would like to join....", owner.username];
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
    frame.size.height -= 20;
    frame.size.width += 40;
    
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
        
        RTLog(@"sad panda -  %@", NSStringFromCGRect(backgroundPaginationView.frame));
        
        [self.view addSubview:backgroundPaginationView];
        [self.view addSubview:_pageControl];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
