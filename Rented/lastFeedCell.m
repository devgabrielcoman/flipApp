//
//  lastFeedCell.m
//  Rented
//
//  Created by Cristian Olteanu on 2/12/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "lastFeedCell.h"

@implementation lastFeedCell

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
