//
//  AddApartmentViewController.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddApartmentViewController : UIViewController

@property CLLocationCoordinate2D apartmentLocation;
@property NSString *locationName;
@property NSInteger apartmentType;
@property NSArray *apartmentImages;
@property PFUser *apartmentOwner;

@end
