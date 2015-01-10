//
//  LikedApartment.h
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikedApartment : UIImageView

- (instancetype)initWithSize:(CGSize)size inParentFrame:(CGRect)parentFrame;
- (void)displayInParentView:(UIView *)container;
- (void)removeFromParentView;

@end
