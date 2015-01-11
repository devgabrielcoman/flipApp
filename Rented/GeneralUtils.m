//
//  GeneralUtils.m
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "GeneralUtils.h"

@implementation GeneralUtils

+ (NSString *)roomsDescriptionForApartment:(PFObject *)apartment
{
    NSMutableString *rooms = [NSMutableString new];
    NSArray *roomsArray = apartment[@"rooms"];
    
    for (NSNumber *roomType in roomsArray)
    {
        if([roomType integerValue] == Studio)
            [rooms appendFormat:@"Studio"];
        
        if([roomType integerValue] == Bedroom1)
            [rooms appendFormat:@", 1 Bedroom"];
        
        if([roomType integerValue] == Bedrooms2)
            [rooms appendFormat:@", 2 Bedrooms"];
        
        if([roomType integerValue] == Bedrooms3)
            [rooms appendFormat:@", 3 Bedrooms"];
        
        if([roomType integerValue] == Bedrooms4)
            [rooms appendFormat:@", 3 Bedrooms"];
    }
    
    NSString *finalString;
    
    if([[rooms substringToIndex:1] isEqualToString:@","])
        finalString = [rooms substringFromIndex:1];
    else
        finalString = rooms;
    
    return finalString;
}

@end