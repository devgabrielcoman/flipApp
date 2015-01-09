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

@interface FeedViewController ()<UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, ApartmentCellProtocol>
{
    NSIndexPath *expandedRow;
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
    
    if([DEP.api.userApi userIsAuthenticated])
    {
        [DEP.api.apartmentApi getFeedApartments:^(NSArray *apartments, BOOL succeeded) {
            if(succeeded)
            {
                self.apartments = apartments;
                [self.tableView reloadData];
            }
        }];
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
    return _apartments.count;
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
    
    Apartment *ap = _apartments[indexPath.row];
    
    [cell setApartmentIndex:indexPath.row];
    [cell setApartment:ap.apartment andImages:ap.images];
    [cell setDelegate:self];
    cell.currentUserIsOwner = NO;
    
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
