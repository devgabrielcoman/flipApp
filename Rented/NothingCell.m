//
//  NothingCell.m
//  Rented
//
//  Created by Cristian Olteanu on 2/13/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "NothingCell.h"

@implementation NothingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)shareFlip
{
    [self.delegate shareFlip];
}

@end
