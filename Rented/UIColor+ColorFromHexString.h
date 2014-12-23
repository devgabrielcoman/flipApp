//
//  UIColor+ColorFromHexString.h
//  Rented
//
//  Created by Lucian Gherghel on 23/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromHexString)

+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (NSString*) colorToHex:(UIColor*)color;

@end
