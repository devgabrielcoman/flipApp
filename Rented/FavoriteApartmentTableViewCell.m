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
    
    _apartmentImageView.layer.cornerRadius = 2.5;
    _apartmentImageView.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    

}




@end
