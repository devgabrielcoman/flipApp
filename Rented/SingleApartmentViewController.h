//
//  MyPlaceViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApartmentCellProtocol.h"
#import "Apartment.h"

@interface SingleApartmentViewController : UIViewController<ApartmentCellProtocol>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) IBOutlet UILabel* loadingLabel;
@property (nonatomic, strong) NSString* apartmentId;

@property Apartment *apartment;
@property BOOL isFromFavorites;

@property BOOL userIsOwner;

@end
