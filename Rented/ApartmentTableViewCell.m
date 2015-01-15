//
//  DemoApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentTableViewCell.h"
#import "GeneralUtils.h"


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
    _apartmentDetailsView.delegate = delegate;
}

- (void)setApartment:(PFObject *)apartment withImages:(NSArray *)images andCurrentUsersStatus:(BOOL)isOwner;
{
    [_apartmentTopView setApartmentDetails:apartment andImages:images];
    _currentUserIsOwner = isOwner;
    
    if(_currentUserIsOwner)
    {
        _apartmentDetailsView = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsView" owner:self options:nil] firstObject];
        _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsViewHeight);
        
        _apartmentTopView.connectedThroughImgView.alpha = 0.0;
        _apartmentTopView.connectedThroughLbl.alpha = 0.0;
        
        _apartmentDetailsView.connectedThroughImageView.alpha = 0.0;
        _apartmentDetailsView.connectedThroughLbl.alpha = 0.0;
    }
    else
    {
        _apartmentDetailsView = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsOtherListingView" owner:self options:nil] firstObject];
        _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsOtherListingViewHeight);
        
        _apartmentTopView.connectedThroughImgView.alpha = 1.0;
        _apartmentDetailsView.connectedThroughImageView.alpha = 1.0;
        
        PFUser *apartmentOwner = apartment[@"owner"];
        [DEP.api.userApi getFacebookMutualFriendsWithFriend:apartmentOwner[@"facebookID"] completionHandler:^(NSArray *mutualFriends, BOOL succeeded) {
            if(succeeded)
            {
                if(mutualFriends)
                {
                    if(mutualFriends.count == 0)
                    {
                        _apartmentTopView.connectedThroughLbl.text = @"";
                        _apartmentDetailsView.connectedThroughLbl.text = @"";
                    }
                    else
                    {
                        _apartmentTopView.connectedThroughLbl.text = @"";// [NSString stringWithFormat:@"%lu", (unsigned long)mutualFriends.count];
                        _apartmentDetailsView.connectedThroughLbl.text = @""; // [GeneralUtils connectedThroughExtendedDescription:[[NSMutableArray alloc] initWithArray:mutualFriends]];
                    }
                    
                }
                else
                {
                    _apartmentTopView.connectedThroughLbl.text = @"";
                    _apartmentDetailsView.connectedThroughLbl.text = @"";
                }
            }
            else
            {
                _apartmentTopView.connectedThroughLbl.text = @"";
                _apartmentDetailsView.connectedThroughLbl.text = @"";
            }
            
            _apartmentTopView.connectedThroughLbl.alpha = 1.0;
            _apartmentDetailsView.connectedThroughLbl.alpha = 1.0;
        }];
    }
    
    _apartmentDetailsView.currentUserIsOwner = isOwner;
    _apartmentDetailsView.isFromFavorites = _isFromFavorites;
    [_apartmentDetailsView setApartmentDetails:apartment];
    _apartmentDetailsView.isFromFavorites = _isFromFavorites;
    _apartmentTopView.apartment = apartment;
}

- (void)setApartmentIndex:(NSInteger)apartmentIndex
{
    [_apartmentTopView setApartmentIndex:apartmentIndex];
    _apartmentDetailsView.apartmentIndex = apartmentIndex;
    _index = apartmentIndex;
}

- (void)showApartmentDetails
{
//check again
    [_apartmentDetailsView updateFlipButtonStatus];
    _apartmentTopView.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);
    [_apartmentTopView layoutIfNeeded];
    
    if(_currentUserIsOwner)
        _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsViewHeight);
    else
        _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsOtherListingViewHeight);
    
    [self addSubview:_apartmentDetailsView];
    _apartmentDetailsView.alpha = 1.0;
    
    [_apartmentTopView.displayMore setTitle:@"hide" forState:UIControlStateNormal];
}

- (void)hideApartmentDetails
{
//check again
    [_apartmentDetailsView removeFromSuperview];
    _apartmentTopView.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);
    
    _apartmentDetailsView = nil;
    
    [_apartmentTopView layoutIfNeeded];
    [_apartmentTopView.displayMore setTitle:@"show more" forState:UIControlStateNormal];
}

@end
