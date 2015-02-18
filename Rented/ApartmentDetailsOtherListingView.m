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
#import "CongratulationsViewController.h"
#import "UnflipedViewController.h"

@implementation ApartmentDetailsOtherListingView

- (void)awakeFromNib
{

    
    
    [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47a0db"]] forState:UIControlStateNormal];
    
    [_likeBtn.layer setCornerRadius:5.0];
    [_likeBtn setClipsToBounds:YES];
    [_shareBtn.layer setCornerRadius:5.0];
    [_shareBtn setClipsToBounds:YES];

    

}

- (void)setApartmentDetails:(PFObject *)apartment
{
    
    //customise apartment details
    
    _apartment = apartment;
    _descriptionLabel.text = apartment[@"description"];
    
    NSMutableString *vacancy = [[NSMutableString alloc] initWithString:@""];
    NSArray *vacancyArray = apartment[@"vacancy"];
    
    for (NSNumber *vacancyType in vacancyArray)
    {
        if([vacancyType integerValue] == VacancyLongTerm)
            [vacancy appendFormat:@"Long-Term"];
        
        if([vacancyType integerValue] == VacancyFlexible)
            [vacancy appendFormat:@"Flexible"];
        
        if([vacancyType integerValue] == VacancyShortTerm)
            [vacancy appendFormat:@"Short-Term"];
    }
//    for (NSNumber *rentIncrease in apartment[@"rentWillChange"])
//    {
//        if ([rentIncrease integerValue] == RentWillChangeYES)
//        {
//            _rentIncreaseLbl.text = @"Rent increase: Yes";
//        }
//        if ([rentIncrease integerValue] == RentWillChangeNO)
//        {
//            _rentIncreaseLbl.text = @"Rent increase: No";
//        }
//        if ([rentIncrease integerValue] == RentWillChangeMaybe)
//        {
//            _rentIncreaseLbl.text = @"Rent increase: Maybe";
//        }
//    }
    
    for (NSNumber *fee in apartment[@"fee"])
    {
        if ([fee integerValue] == Fee3percent)
        {
            _feeLbl.text = [NSString stringWithFormat:@"$%d",(int)(0.03*[apartment[@"rent"] integerValue])];
        }
        if ([fee integerValue] == Fee6percent)
        {
            _feeLbl.text = [NSString stringWithFormat:@"$%d",(int)(0.06*[apartment[@"rent"] integerValue])];
        }
        if ([fee integerValue] == Fee9percent)
        {
            _feeLbl.text = [NSString stringWithFormat:@"$%d",(int)(0.09*[apartment[@"rent"] integerValue])];
        }
        if ([fee integerValue] == FeeOtherpercent)
        {
            _feeLbl.text = [NSString stringWithFormat:@"$%d",(int)([apartment[@"feeOther"] floatValue]*[apartment[@"rent"] integerValue])];
        }
    }
    
    _vacancyLbl.text = vacancy;
    
    if(apartment[@"city"])
    {
        if(apartment[@"state"])
        {
            _cityLbl.text=[NSString stringWithFormat:@"%@, %@",apartment[@"city"],apartment[@"state"]];
        }
        else
        {
            _cityLbl.text=apartment[@"city"];
        }
    }
    else
    {
        _cityLbl.text = [GeneralUtils getCityFromLocation:apartment[@"locationName"]];
    }
    _componentRoomsLbl.text = [GeneralUtils roomsDescriptionForApartment:apartment];
    
    _priceLbl.text = [NSString stringWithFormat:@"$%@",apartment[@"rent"]];
    _sizeLbl.text = [NSString stringWithFormat:@"%@ sq ft", apartment[@"area"]];
    
    if(apartment[@"renewalTimestamp"])
    {
        NSDate* renewalDate = [NSDate dateWithTimeIntervalSince1970:(long)[apartment[@"renewalTimestamp"] integerValue]];
        NSTimeInterval secondsInterval = [renewalDate timeIntervalSinceDate:[NSDate date]];
        int numberOfDays = secondsInterval /86400 +1;
        if (numberOfDays == 1)
        {
            _remainingDays.text = [NSString stringWithFormat:@"%d day",numberOfDays];
        }
        else
        {
            _remainingDays.text = [NSString stringWithFormat:@"%d days",numberOfDays];
        }
    }
    else
    {
        _remainingDays.text = [NSString stringWithFormat:@"%li days", (long)[apartment[@"renewaldays"] integerValue]];
    }
    
    if (apartment[@"neighborhood"])
    {
        _neighborhoodLabel.text = apartment[@"neighborhood"];
    }
    else
    {
        _neighborhoodLabel.text = @"";
    }

    if ([DEP.favorites containsObject: _apartment.objectId])
    {
        [_likeBtn setSelected:YES];
    }
    else
    {
        [_likeBtn setSelected:NO];
    }
    
    
    CGRect labelRect = [(NSString*)apartment[@"description"]
                        boundingRectWithSize:CGSizeMake(_descriptionLabel.frame.size.width, 500)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0]
                                     }
                        context:nil];

    if (labelRect.size.height > 74)
    {
        [_moreBtn setHidden:NO];
    }
    else
    {
        [_moreBtn setHidden:YES];
    }
    
    if([_apartment[@"requested"] integerValue] == 1)
    {
        [self.getButton setTitle:@"REQUESTED" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"CCCCCC"]] forState:UIControlStateNormal];
    }
    else
    {
        [self.getButton setTitle:@"GET" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47A0DB"]] forState:UIControlStateNormal];
    }

    
}

-(IBAction)likeButtonTapped:(id)sender
{
    if (_likeBtn.selected)
    {
        [_likeBtn setSelected:!_likeBtn.selected];
        [DEP.api.apartmentApi removeApartmentFromFavorites:_apartment completion:^(BOOL succeeded) {}];
        [DEP.favorites removeObject:_apartment.objectId];
    }
    else
    {
        [_likeBtn setSelected:!_likeBtn.selected];
        [DEP.api.apartmentApi addApartmentToFavorites:_apartment withNotification:YES completion:^(BOOL succeeded) {}];
        [DEP.favorites addObject:_apartment.objectId];
    }

}

- (void)updateFlipButtonStatus
{
    
    if (self.currentUserIsOwner)
    {
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47A0DB"]] forState:UIControlStateNormal];

        if ([_apartment[@"visible"] integerValue]==1)
        {
            [self.getButton setTitle:@"UNFLIP" forState:UIControlStateNormal];
        }
        else
        {
            [self.getButton setTitle:@"FLIP" forState:UIControlStateNormal];
            
        }
        return;
    }
 
    if([_apartment[@"requested"] integerValue] == 1)
    {
        [self.getButton setTitle:@"REQUESTED" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"CCCCCC"]] forState:UIControlStateNormal];
    }
    else
    {
        [self.getButton setTitle:@"GET" forState:UIControlStateNormal];
        [_getButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHexString:@"47A0DB"]] forState:UIControlStateNormal];
    }
    
}

- (IBAction)getApartment:(id)sender
{
    if (self.currentUserIsOwner)
    {

        if(![_apartment[@"visible"] boolValue])
        {
            [DEP.api.apartmentApi makeApartmentLive:_apartment completion:^(BOOL succeeded) {
                
            }];
            
            
            [[[UIAlertView alloc]initWithTitle:@"Your listing is now visible!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self.getButton setTitle:@"UNFLIP" forState:UIControlStateNormal];
            
            
        }
        else
        {
            [DEP.api.apartmentApi hideLiveApartment:_apartment completion:^(BOOL succeeded) {
                
            }];
            
            [[[UIAlertView alloc]initWithTitle:@"OK! Your listing is hidden" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

                
    
            
            
            [self.getButton setTitle:@"FLIP" forState:UIControlStateNormal];
            
        }
        
        return;
    }

    [_apartmentDetailsDelegate getApartmentAtIndex:_apartmentIndex];
}

-(IBAction)showDescription:(id)sender
{
    [self.controller setTitle:@" "];
    UIViewController* descriptionVC = [UIViewController new];
    
    CGRect labelRect = [(NSString*)_apartment[@"description"]
                        boundingRectWithSize:CGSizeMake(_descriptionLabel.frame.size.width, 5000)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16.0]
                                     }
                        context:nil];
    
    UILabel * descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(_descriptionLabel.frame.origin.x, _descriptionLabel.frame.origin.y-60, _descriptionLabel.frame.size.width, labelRect.size.height+10)];
    descriptionLabel.numberOfLines =0;
    descriptionLabel.text = _descriptionLabel.text;
    descriptionLabel.font = _descriptionLabel.font;
    descriptionLabel.textColor = _descriptionLabel.textColor;
    
    [descriptionVC setView:[[UIScrollView alloc] initWithFrame:self.frame]];
    [(UIScrollView*)descriptionVC.view setContentSize:CGSizeMake(descriptionLabel.frame.size.width, descriptionLabel.frame.size.height+ 60)];
    [descriptionVC.view addSubview:descriptionLabel];
    [descriptionVC.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.controller.navigationController pushViewController:descriptionVC animated:YES];
    

}
-(IBAction)pressedShareButton:(id)sender
{
    
    NSString *textToShare = @"Check out this apartment!";
    if ([textToShare isEqualToString:@""])
    {
        textToShare =@" ";
    }

    NSURL *url = [NSURL URLWithString:self.apartment[@"shareUrl"]];
    UIImage* image = self.firstImageView.image;
    
    NSArray *objectsToShare;
    
    if (image)
    {
        objectsToShare = @[textToShare, url,image];
    }
    else
    {
        objectsToShare = @[textToShare, url,image];

    }
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self.controller presentViewController:activityVC animated:YES completion:nil];
}

@end
