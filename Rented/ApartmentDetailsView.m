//
//  ApartmentDetailsView.m
//  Rented
//
//  Created by Lucian Gherghel on 07/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentDetailsView.h"
#import "UIColor+ColorFromHexString.h"

@implementation ApartmentDetailsView

- (void)awakeFromNib
{
    _descriptionTextView.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _vacancyLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _priceLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _sizeLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _componentRoomsLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
    _flipBtn.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.0];
    _flipBtn.backgroundColor = [UIColor colorFromHexString:@"47a0db"];
}

- (void)setApartmentDetails:(PFObject *)apartment
{
    _descriptionTextView.text = apartment[@"description"];
//    _vacancyLbl.text = @"";
    _priceLbl.text = [NSString stringWithFormat:@"%@ $",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
    _componentRoomsLbl.text = apartment[@"components"];
}

@end
