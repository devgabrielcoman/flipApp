//
//  FavoriteApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "FavoriteApartmentTableViewCell.h"

@implementation FavoriteApartmentTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    _apartmentDescriptionLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _locationLbl.font = [UIFont fontWithName:@"GothamRounded-Light" size:12.0];
    _apartmentImageView.layer.cornerRadius = 6.0;
    _apartmentImageView.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
