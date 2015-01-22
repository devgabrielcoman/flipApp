//
//  ApartmentDetailsOtherListingView.m
//  Rented
//
//  Created by Gherghel Lucian on 15/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentDetailsOtherListingView.h"
#import "UIColor+ColorFromHexString.h"
#import "GeneralUtils.h"
#import "UIImage+imageWithColor.h"
#import "UIImage+ProportionalFill.h"

@implementation ApartmentDetailsOtherListingView

- (void)awakeFromNib
{
    _descriptionTextView.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _vacancyLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _priceLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _sizeLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _componentRoomsLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _cityLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    _remainingDays.font = [UIFont fontWithName:@"GothamRounded-Light" size:13.0];
    
    _vacancyLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _priceLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _sizeLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _componentRoomsLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _connectedThroughLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _cityLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _remainingDays.textColor = [UIColor colorFromHexString:FeedTextColor];
    
    _getButton.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.0];
    [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    
    _messageBtn.titleLabel.font = [UIFont fontWithName:@"GothamRounded-Light" size:15.0];
    [_messageBtn setTintColor:[UIColor colorFromHexString:FeedTextColor]];
    
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _connectedThroughImageView.image = [[UIImage imageNamed:@"users"] imageScaledToFitSize:_connectedThroughImageView.frame.size];
}

- (void)setApartmentDetails:(PFObject *)apartment
{
    _apartment = apartment;
    _descriptionTextView.text = apartment[@"description"];
    
    NSMutableString *vacancy = [[NSMutableString alloc] initWithString:@"Vacancy: "];
    NSArray *vacancyArray = apartment[@"vacancy"];
    
    for (NSNumber *vacancyType in vacancyArray)
    {
        if([vacancyType integerValue] == VacancyImmediate)
            [vacancy appendFormat:@"Immediate"];
        
        if([vacancyType integerValue] == VacancyNegociable)
            [vacancy appendFormat:@"Negociable"];
        
        if([vacancyType integerValue] == VacancyShortTerm)
            [vacancy appendFormat:@"Short-Term"];
    }
    
    _vacancyLbl.text = vacancy;
    
    RTLog(@"apartment location: %@", apartment[@"locationName"]);
    _cityLbl.text = [GeneralUtils getCityFromLocation:apartment[@"locationName"]];
    
    _componentRoomsLbl.text = [GeneralUtils roomsDescriptionForApartment:apartment];
    
    _priceLbl.text = [NSString stringWithFormat:@"$%@",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
    
    _remainingDays.text = [NSString stringWithFormat:@"%li days until renewal", (long)[apartment[@"renewaldays"] integerValue]];
}

- (void)updateFlipButtonStatus
{
    
}

- (IBAction)getApartment:(id)sender
{
    [_delegate getApartmentAtIndex:_apartmentIndex];
}

@end
