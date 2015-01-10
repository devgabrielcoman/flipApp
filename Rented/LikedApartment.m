//
//  LikedApartment.m
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "LikedApartment.h"

@implementation LikedApartment

- (instancetype)initWithSize:(CGSize)size inParentFrame:(CGRect)parentFrame
{
    if ((self = [super init]))
    {
        //center heart in parent view
        CGPoint center;
        center.x = parentFrame.size.width/2 - size.width/2;
        center.y = parentFrame.size.height/2 - size.height/2;
        
        self.frame = CGRectMake(center.x, center.y, size.width, size.height);
    }
    
    return self;
}

- (void)displayInParentView:(UIView *)container
{
    self.alpha = 0.0f;
    [container addSubview:self];
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.alpha = 1.0f;
                     }
                     completion:nil];
}

- (void)removeFromParentView
{
    [UIView animateWithDuration:0.4
                          delay:1.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
