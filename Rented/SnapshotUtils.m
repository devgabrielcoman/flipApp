//
//  SnapshotUtils.m
//  Rented
//
//  Created by Lucian Gherghel on 21/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "SnapshotUtils.h"

@implementation SnapshotUtils

+(UIImage *)takeSnapshot:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, view.frame);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
