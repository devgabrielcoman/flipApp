//
//  FavoritesTableViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteApartmentCellProtocol.h"
#import "ApartmentCellProtocol.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "ApartmentDetailsOtherListingView.h"

@interface FavoritesTableViewController : UITableViewController<FavoriteApartmentCellProtocol,ApartmentCellProtocol>

@property NSMutableArray *favoriteApartments;
@property NSInteger indexForGetRequest;

@property ApartmentDetailsOtherListingView* details;
@end
