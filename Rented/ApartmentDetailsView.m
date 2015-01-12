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
#import "UIImage+imageWithColor.h"

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
    [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    //_flipBtn.backgroundColor = [UIColor lightGrayColor];
}

- (void)setApartmentDetails:(PFObject *)apartment
{
    _apartment = apartment;
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
    
    _componentRoomsLbl.text = [GeneralUtils roomsDescriptionForApartment:apartment];
    
    _priceLbl.text = [NSString stringWithFormat:@"%@ $",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
}

- (void)updateFlipButtonStatus
{
    if(_currentUserIsOwner)
    {
        [_flipBtn setTitle:@"FLIP" forState:UIControlStateNormal];
        if([_apartment[@"visible"] boolValue])
        {
            //user already flipped his apartmen aka made it visible on screen
            //_flipBtn.backgroundColor = [UIColor lightGrayColor];
            [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            _flipBtn.enabled = NO;
        }
        else
        {
            //else, should be flipped
            //_flipBtn.backgroundColor = [UIColor colorFromHexString:@"47a0db"];
            [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
            _flipBtn.enabled = YES;
        }
    }
    else
    {
        [_flipBtn setTitle:@"GET" forState:UIControlStateNormal];
        [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
        _flipBtn.enabled = YES;
    }
}

- (IBAction)flipBtn:(id)sender
{
    if(_currentUserIsOwner)
    {
        if(![_apartment[@"visible"] boolValue])
            [DEP.api.apartmentApi makeApartmentLive:_apartment completion:^(BOOL succeeded) {
                _flipBtn.enabled = NO;
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
                                 }];
            }];
    }
    else
    {
        [_delegate getApartmentAtIndex:_apartmentIndex];
    }
}
@end
