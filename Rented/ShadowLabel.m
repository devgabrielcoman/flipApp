//
//  ShadowLabel.m
//  Rented
//
//  Created by Cristian Olteanu on 2/17/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "ShadowLabel.h"

@implementation ShadowLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) drawTextInRect:(CGRect)rect {
    CGSize myShadowOffset = CGSizeMake(0, 1);
    CGFloat myColorValues[] = {0, 0, 0, .4};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor (myContext, myShadowOffset, 1, myColor);
    
    [super drawTextInRect:rect];
    
    CGColorRelease(myColor);
    CGColorSpaceRelease(myColorSpace);
    
    CGContextRestoreGState(myContext);
}

@end
