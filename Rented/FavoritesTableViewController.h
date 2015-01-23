//
//  FavoritesTableViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteApartmentCellProtocol.h"

@interface FavoritesTableViewController : UITableViewController<FavoriteApartmentCellProtocol>

@property NSMutableArray *favoriteApartments;

@end
