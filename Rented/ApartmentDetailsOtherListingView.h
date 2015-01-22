//
//  ApartmentDetailsOtherListingView.h
//  Rented
//
//  Created by Gherghel Lucian on 15/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ApartmentCellProtocol.h"
#import "ApartmentDetailsViewProtocol.h"

@interface ApartmentDetailsOtherListingView : UIView<ApartmentDetailsViewProtocol>

@property (weak, nonatomic) IBOutlet UILabel *vacancyLbl;
@property (weak, nonatomic) IBOutlet UILabel *priceLbl;
@property (weak, nonatomic) IBOutlet UILabel *sizeLbl;
@property (weak, nonatomic) IBOutlet UILabel *componentRoomsLbl;
@property (weak, nonatomic) IBOutlet UILabel *cityLbl;
@property (weak, nonatomic) IBOutlet UIImageView *connectedThroughImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectedThroughLbl;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *remainingDays;

@property PFObject *apartment;
@property BOOL currentUserIsOwner;
@property id<ApartmentCellProtocol> delegate;
@property NSInteger apartmentIndex;
@property BOOL isFromFavorites;

- (void)setApartmentDetails:(PFObject *)apartment;
- (void)updateFlipButtonStatus;

@end
