//
//  GeneralUtils.m
//  Rented
//
//  Created by Lucian Gherghel on 10/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "GeneralUtils.h"
#import "FacebookFriend.h"

@implementation GeneralUtils

+ (NSString *)roomsDescriptionForApartment:(PFObject *)apartment
{
    NSMutableString *rooms = [NSMutableString new];
    NSArray *roomsArray = apartment[@"rooms"];
    
    for (NSNumber *roomType in roomsArray)
    {
        if([roomType integerValue] == Studio)
            [rooms appendFormat:@", Studio"];
        
        if([roomType integerValue] == Bedroom1)
            [rooms appendFormat:@", 1 Bedroom"];
        
        if([roomType integerValue] == Bedrooms2)
            [rooms appendFormat:@", 2 Bedrooms"];
        
        if([roomType integerValue] == Bedrooms3)
            [rooms appendFormat:@", 3 Bedrooms"];
        
        if([roomType integerValue] == Bedrooms4)
            [rooms appendFormat:@", 4 Bedrooms"];
    }
    
    NSString *finalString = @"";
    
    if(rooms.length > 1 && [[rooms substringToIndex:1] isEqualToString:@","])
        finalString = [rooms substringFromIndex:1];
    else
        finalString = rooms;
    
    return finalString;
}

+ (NSString *)connectedThroughExtendedDescription:(NSMutableArray *)mutalFriends
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"Connected through "];
    if(mutalFriends.count == 1)
    {
        FacebookFriend *fr = [mutalFriends firstObject];
        [description appendFormat:@"%@", fr.name];
    } else {
        FacebookFriend *fr = [mutalFriends firstObject];
        [mutalFriends removeObject:fr];
        [description appendFormat:@"%@ and %lu others", fr.name, (unsigned long)mutalFriends.count];
    }
    
    return description;
}

+ (NSString *)getCityFromLocation:(NSString *)locationString
{
    NSString *substring1 = [locationString substringToIndex:[locationString rangeOfString:@", " options:NSBackwardsSearch].location];
    NSInteger location2 = [substring1 rangeOfString:@", " options:NSBackwardsSearch].location;
    
    return [substring1 substringFromIndex:location2+2];
}

@end
