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

@interface FavoritesTableViewController ()

@end

@implementation FavoritesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteApartmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"FavoriteApartmentCell"];
    
    [DEP.api.apartmentApi getListOfFavoritesApartments:^(NSArray *favoriteApartments, BOOL succeeded) {
        if(succeeded)
        {
            _favoriteApartments = favoriteApartments;
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
    return 120.0f;
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
        cell.apartmentImageView.showActivityIndicator = YES;
        cell.apartmentImageView.imageURL = [NSURL URLWithString:imageFile.url];
    }
    
    PFUser *owner = ap.apartment[@"owner"];
    
    cell.apartmentDescriptionLbl.text = [NSString stringWithFormat:@"%@'s apartment", owner.username];
    cell.locationLbl.text = ap.apartment[@"locationName"];
    
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Apartment *ap = _favoriteApartments[indexPath.row];
    SingleApartmentViewController *apartmentViewController = [SingleApartmentViewController new];
    apartmentViewController.apartment = ap;
    apartmentViewController.isFromFavorites = YES;
    
    [self.navigationController pushViewController:apartmentViewController animated:YES];
}



@end
