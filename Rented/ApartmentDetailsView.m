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
#import "UIImage+ProportionalFill.h"

@implementation ApartmentDetailsView

- (void)awakeFromNib
{
    _descriptionTextView.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _vacancyLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _priceLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _sizeLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _componentRoomsLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:11.0];
    
    _vacancyLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _priceLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _sizeLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _componentRoomsLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    _connectedThroughLbl.textColor = [UIColor colorFromHexString:FeedTextColor];
    
    _flipBtn.titleLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.0];
    [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    
    _connectedThroughLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _connectedThroughImageView.image = [[UIImage imageNamed:@"users"] imageScaledToFitSize:_connectedThroughImageView.frame.size];
    
    //_flipBtn.backgroundColor = [UIColor lightGrayColor];
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
        
        if([vacancyType integerValue] == VacancyFlexible)
            [vacancy appendFormat:@"Flexible"];
        
        if([vacancyType integerValue] == VacancyShortTerm)
            [vacancy appendFormat:@"Short-Term"];
    }
    _vacancyLbl.text = vacancy;
    
    _componentRoomsLbl.text = [GeneralUtils roomsDescriptionForApartment:apartment];
    
    _priceLbl.text = [NSString stringWithFormat:@"$%@",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
}

- (void)updateFlipButtonStatus
{
    if(!_isFromFavorites)
    {
        if(_currentUserIsOwner)
        {
            [_flipBtn setTitle:@"FLIP" forState:UIControlStateNormal];
            if([_apartment[@"visible"] boolValue])
            {
                //user already flipped his apartmen aka made it visible on screen
                //_flipBtn.backgroundColor = [UIColor lightGrayColor];
                [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
                _flipBtn.enabled = YES;
                [_flipBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];
                
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
                _flipBtn.enabled = YES;
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
                                     [_flipBtn setTitle:@"UNFLIP" forState:UIControlStateNormal];
                                 }];
            }];
        else
            [DEP.api.apartmentApi hideLiveApartment:_apartment completion:^(BOOL succeeded) {
                _flipBtn.enabled = YES;
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     [_flipBtn setTitle:@"FLIP" forState:UIControlStateNormal];
                                     [_flipBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
                                 }];
            }];
            
    }
    else
    {
        [_delegate getApartmentAtIndex:_apartmentIndex];
    }
}
@end
