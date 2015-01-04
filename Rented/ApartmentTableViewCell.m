//
//  ApartmentTableViewCell.m
//  Rented
//
//  Created by Lucian Gherghel on 04/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ApartmentTableViewCell.h"

@implementation ApartmentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    RTLog(@"cell frame: %@", NSStringFromCGRect(self.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
