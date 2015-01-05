//
//  MyPlaceViewController.h
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApartmentCellProtocol.h"

@interface MyPlaceViewController : UITableViewController<ApartmentCellProtocol>

@property PFObject *apartment;
@property NSArray *apartmentImages;

@end
