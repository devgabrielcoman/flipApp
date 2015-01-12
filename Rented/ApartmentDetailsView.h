//
//  ApartmentDetailsView.h
//  Rented
//
//  Created by Lucian Gherghel on 07/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApartmentCellProtocol.h"

@interface ApartmentDetailsView : UIView

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *vacancyLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UILabel *sizeLbl;
@property (weak, nonatomic) IBOutlet UILabel *componentRoomsLbl;
@property (weak, nonatomic) IBOutlet UIImageView *connectedThroughImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectedThroughLbl;
@property (weak, nonatomic) IBOutlet UIButton *flipBtn;

@property PFObject *apartment;
@property BOOL currentUserIsOwner;
@property id<ApartmentCellProtocol> delegate;
@property NSInteger apartmentIndex;

- (void)setApartmentDetails:(PFObject *)apartment;
- (void)updateFlipButtonStatus;

@end
