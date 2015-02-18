//
//  AddApartmentViewController.h
//  RentedAddApartment
//
//  Created by Lucian Gherghel on 30/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Apartment.h"


@protocol AddApartmentDelegate <NSObject>

-(void)addApartmentFinieshedWithChanges:(BOOL) changes;

@end

@interface AddApartmentViewController : UIViewController 

@property id <AddApartmentDelegate> delegate;
@property CLLocationCoordinate2D apartmentLocation;
@property NSString *locationName;
@property NSInteger apartmentType;
@property NSArray *apartmentImages;
@property PFUser *apartmentOwner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContainer;



@property Apartment* apartment;
@property UIImage* image;

@end
