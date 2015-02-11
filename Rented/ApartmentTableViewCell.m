//
//  DemoApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentTableViewCell.h"
#import "GeneralUtils.h"
#import "AppDelegate.h"
#import "RentedPanelController.h"

@implementation ApartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.frame = CGRectMake(0, 0, wScr, hScr);
    
    _apartmentTopView = [[[NSBundle mainBundle] loadNibNamed:@"TopApartmentView" owner:self options:nil] firstObject];
    [self.contentView addSubview:_apartmentTopView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDelegate:(id<ApartmentCellProtocol>)delegate
{
    _apartmentTopView.delegate = delegate;
}

- (void)setApartment:(PFObject *)apartment withImages:(NSArray *)images andCurrentUsersStatus:(BOOL)isOwner;
{
    [_apartmentTopView setApartmentDetails:apartment andImages:images];
    _currentUserIsOwner = isOwner;
    _apartmentTopView.connectedThroughLbl.text = @"";
    
    if(_currentUserIsOwner)
    {
        
        _apartmentTopView.connectedThroughImgView.alpha = 0.0;
        _apartmentTopView.connectedThroughLbl.alpha = 0.0;
        [_apartmentTopView.myListingBar setHidden:NO];
        
    }
    else
    {
  
        _apartmentTopView.connectedThroughImgView.alpha = 1.0;
        NSArray* mutualFriends=[GeneralUtils mutableFriendsInArray1:apartment[@"owner"][@"facebookFriends"] andArray2:[PFUser currentUser][@"facebookFriends"]];
        NSUInteger numberOfFriends=[mutualFriends count];
        [_apartmentTopView.myListingBar setHidden:YES];
        _apartmentTopView.connectedThroughLbl.text = [NSString stringWithFormat:@"%lu",(unsigned long)numberOfFriends];


    }

    _apartmentTopView.apartment = apartment;

}

- (void)setApartmentIndex:(NSInteger)apartmentIndex
{
    [_apartmentTopView setApartmentIndex:apartmentIndex];
    _index = apartmentIndex;
}


@end
