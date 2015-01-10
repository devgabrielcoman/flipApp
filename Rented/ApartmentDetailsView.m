//
//  ApartmentDetailsView.m
//  Rented
//
//  Created by Lucian Gherghel on 07/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentDetailsView.h"
#import "UIColor+ColorFromHexString.h"
#import "GeneralUtils.h"

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
    
    NSMutableString *vacancy = [[NSMutableString alloc] initWithString:@"Vacancy:\n"];
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
    
//    NSMutableString *rooms = [NSMutableString new];
//    NSArray *roomsArray = apartment[@"rooms"];
//    
//    for (NSNumber *roomType in roomsArray)
//    {
//        if([roomType integerValue] == Studio)
//            [rooms appendFormat:@"Studio"];
//        
//        if([roomType integerValue] == Bedroom1)
//            [rooms appendFormat:@", 1 Bedroom"];
//        
//        if([roomType integerValue] == Bedrooms2)
//            [rooms appendFormat:@", 2 Bedrooms"];
//        
//        if([roomType integerValue] == Bedrooms3)
//            [rooms appendFormat:@", 3 Bedrooms"];
//        
//        if([roomType integerValue] == Bedrooms4)
//            [rooms appendFormat:@", 3 Bedrooms"];
//    }
    
    _componentRoomsLbl.text = [GeneralUtils roomsDescriptionForApartment:apartment];
    
    _priceLbl.text = [NSString stringWithFormat:@"%@ $",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
}

@end
