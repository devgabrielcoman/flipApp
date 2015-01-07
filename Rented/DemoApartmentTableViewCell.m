//
//  DemoApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 08/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "DemoApartmentTableViewCell.h"


@implementation DemoApartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.frame = CGRectMake(0, 0, wScr, hScr);
    _apartmentTopView = [[[NSBundle mainBundle] loadNibNamed:@"TopApartmentView" owner:self options:nil] firstObject];
    _apartmentDetailsView = [[[NSBundle mainBundle] loadNibNamed:@"ApartmentDetailsView" owner:self options:nil] firstObject];
    //_apartmentDetailsView.frame = CGRectMake(0, hScr, _apartmentDetailsView.frame.size.width, _apartmentDetailsView.frame.size.height);
    
    [self.contentView addSubview:_apartmentTopView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDelegate:(id<ApartmentCellProtocol>)delegate
{
    _apartmentTopView.delegate = delegate;
}

- (void)setApartment:(PFObject *)apartment andImages:(NSArray *)images
{
    [_apartmentTopView setApartmentDetails:apartment andImages:images];
}

- (void)setApartmentIndex:(NSInteger)apartmentIndex
{
    [_apartmentTopView setApartmentIndex:apartmentIndex];
}

- (void)showApartmentDetails
{
    [self.contentView addSubview:_apartmentDetailsView];
}

- (void)hideApartmentDetails
{
    [_apartmentDetailsView removeFromSuperview];
}

@end
