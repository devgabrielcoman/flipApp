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
    
    _apartmentImageView.layer.cornerRadius = 5.0;
    _apartmentImageView.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //Add a right swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self addGestureRecognizer:recognizer];
}

#pragma mark - Swipe gesture handlers

- (void)handleSwipeRight:(id)gesture
{
    RTLog(@"delete apartment from favorites..");
    [_delegate removeFromApartmentFromFavorites:_apartmentIndex];
}

@end
