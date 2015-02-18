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
#import "GeneralUtils.h"

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
    
    cell.apartmentDescriptionLbl.text = [NSString stringWithFormat:@"%@'s %@ in %@", owner.username,type,location];
//    cell.locationLbl.text = ap.apartment[@"locationName"];
    
    cell.apartmentIndex = indexPath.row;
    cell.delegate = self;
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Apartment *ap = _favoriteApartments[indexPath.row];
    self.title = @" ";
    SingleApartmentViewController *apartmentViewController = [SingleApartmentViewController new];
    apartmentViewController.apartment = ap;
    apartmentViewController.isFromFavorites = YES;
    
    [self.navigationController pushViewController:apartmentViewController animated:YES];
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


@end
