//
//  DemoApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentTableViewCell.h"

@implementation ApartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.frame = CGRectMake(0, 0, wScr, hScr);
    
    _apartmentTopView = [[[NSBundle mainBundle] loadNibNamed:@"TopApartmentView" owner:self options:nil] firstObject];
    [self.contentView addSubview:_apartmentTopView];
    
    _apartmentDetailsView = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsView" owner:self options:nil] firstObject];
    _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsViewHeight);
    
    if(!_currentUserIsOwner)
    {
        _apartmentTopView.connectedThroughImgView.alpha = 0.0;
        _apartmentTopView.connectedThroughLbl.alpha = 0.0;
        
        _apartmentDetailsView.connectedThroughImageView.alpha = 0.0;
        _apartmentDetailsView.connectedThroughLbl.alpha = 0.0;
    }
    
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
    [_apartmentDetailsView setApartmentDetails:apartment];
    _currentUserIsOwner = isOwner;
    _apartmentDetailsView.currentUserIsOwner = isOwner;
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
    
    _apartmentDetailsView.frame = CGRectMake(0, hScr-statusBarHeight, wScr, ApartmentDetailsViewHeight);
    [self addSubview:_apartmentDetailsView];
    _apartmentDetailsView.alpha = 1.0;
    
    [_apartmentTopView.displayMore setTitle:@"hide" forState:UIControlStateNormal];
}

- (void)hideApartmentDetails
{
//check again
    [_apartmentDetailsView removeFromSuperview];
    _apartmentTopView.frame = CGRectMake(0, 0, wScr, hScr-statusBarHeight);
    
    [_apartmentTopView layoutIfNeeded];
    [_apartmentTopView.displayMore setTitle:@"show more" forState:UIControlStateNormal];
}

@end
