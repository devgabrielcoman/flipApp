//
//  DemoApartmentTableViewCell.h
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopApartmentView.h"
#import "ApartmentDetailsView.h"

@protocol ApartmentCellProtocol;

@interface ApartmentTableViewCell : UITableViewCell

@property TopApartmentView *apartmentTopView;
@property ApartmentDetailsView *apartmentDetailsView;
@property NSInteger index;
@property BOOL currentUserIsOwner;

- (void)setDelegate:(id<ApartmentCellProtocol>)delegate;
- (void)setApartment:(PFObject *)apartment andImages:(NSArray *)images;
- (void)setApartmentIndex:(NSInteger)apartmentIndex;

- (void)showApartmentDetails;
- (void)hideApartmentDetails;

@end
