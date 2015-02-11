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
            [rooms appendFormat:@"studio"];
        
        if([roomType integerValue] == Bedroom1)
            [rooms appendFormat:@"1"];
        
        if([roomType integerValue] == Bedrooms2)
            [rooms appendFormat:@"2"];
        
        if([roomType integerValue] == Bedrooms3)
            [rooms appendFormat:@"3"];
        
        if([roomType integerValue] == Bedrooms4)
            [rooms appendFormat:@"4"];
    }
    
    NSString *finalString = @"";
    
    if(rooms.length > 1 && [[rooms substringToIndex:1] isEqualToString:@","])
        finalString = [rooms substringFromIndex:1];
    else
        finalString = rooms;
    
    return finalString;
}

+ (NSString *)roomsLongDescriptionForApartment:(PFObject *)apartment
{
    NSMutableString *rooms = [NSMutableString new];
    NSArray *roomsArray = apartment[@"rooms"];
    
    for (NSNumber *roomType in roomsArray)
    {
        if([roomType integerValue] == Studio)
            [rooms appendFormat:@"Studio"];
        
        if([roomType integerValue] == Bedroom1)
            [rooms appendFormat:@"1 Bedroom"];
        
        if([roomType integerValue] == Bedrooms2)
            [rooms appendFormat:@"2 Bedroom"];
        
        if([roomType integerValue] == Bedrooms3)
            [rooms appendFormat:@"3 Bedroom"];
        
        if([roomType integerValue] == Bedrooms4)
            [rooms appendFormat:@"4 Bedroom"];
    }
    
    NSString *finalString = @"";
    
    if(rooms.length > 1 && [[rooms substringToIndex:1] isEqualToString:@","])
        finalString = [rooms substringFromIndex:1];
    else
        finalString = rooms;
    
    return finalString;
}

+(NSMutableArray*) mutableFriendsInArray1: (NSArray*)friends1 andArray2: (NSArray*)friends2
{
    NSMutableArray* returnedArray = [NSMutableArray new];
    
    for (NSString* facebookId in friends1)
    {
        if ([friends2 containsObject:facebookId])
        {
            [returnedArray addObject:facebookId];
        }
    }
    
    return returnedArray;
}

+ (NSString *)connectedThroughExtendedDescription:(NSMutableArray *)mutalFriends
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"Connected through "];
    NSMutableArray* actualFriends =[NSMutableArray new];
    for (NSString* friend in mutalFriends)
    {
        if ([DEP.facebookFriendsInfo objectForKey:friend])
        {
            [actualFriends addObject:friend];
        }
    }
    if(actualFriends.count == 0)
    {
        description=[@"No Connections" mutableCopy];
    }
    else
    {
        if(actualFriends.count == 1)
        {
            NSString* friendId =[mutalFriends firstObject];
            FacebookFriend *fr = [DEP.facebookFriendsInfo objectForKey:friendId];
            [description appendFormat:@"%@", fr.name];
        } else if(mutalFriends.count == 2)
        {
            NSString* friendId1 =[mutalFriends firstObject];
            NSString* friendId2 =[mutalFriends objectAtIndex:1];

            FacebookFriend *fr1 = [DEP.facebookFriendsInfo objectForKey:friendId1];
            FacebookFriend *fr2 = [DEP.facebookFriendsInfo objectForKey:friendId2];
            [description appendFormat:@"%@ and %@", fr1.name, fr2.name];
        }else{
            NSString* friendId =[mutalFriends firstObject];
            FacebookFriend *fr = [DEP.facebookFriendsInfo objectForKey:friendId];
            [mutalFriends removeObject:fr];
            [description appendFormat:@"%@ and %lu others", fr.name, (unsigned long)mutalFriends.count];
        }
    }
    
    return description;
}

+ (NSString *)getCityFromLocation:(NSString *)locationString
{
//    NSString *substring1 = [locationString substringToIndex:[locationString rangeOfString:@", " options:NSBackwardsSearch].location];
//    NSInteger location2 = [substring1 rangeOfString:@", " options:NSBackwardsSearch].location;
//    
//    return [substring1 substringFromIndex:location2+2];
    if ([locationString containsString:@", "])
    {
        return [locationString substringToIndex:[locationString rangeOfString:@", "].location];
    }
    else
    {
        return locationString;
    }
}

+(NSString*) stateAbbreviationForState:(NSString*) state
{
    
    NSString* lowerCaseState = [state lowercaseString];
    NSDictionary* nameAbbreviations = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"AL",@"alabama",
                         @"AK",@"alaska",
                         @"AZ",@"arizona",
                         @"AR",@"arkansas",
                         @"CA",@"california",
                         @"CO",@"colorado",
                         @"CT",@"connecticut",
                         @"DE",@"delaware",
                         @"DC",@"district of columbia",
                         @"FL",@"florida",
                         @"GA",@"georgia",
                         @"HI",@"hawaii",
                         @"ID",@"idaho",
                         @"IL",@"illinois",
                         @"IN",@"indiana",
                         @"IA",@"iowa",
                         @"KS",@"kansas",
                         @"KY",@"kentucky",
                         @"LA",@"louisiana",
                         @"ME",@"maine",
                         @"MD",@"maryland",
                         @"MA",@"massachusetts",
                         @"MI",@"michigan",
                         @"MN",@"minnesota",
                         @"MS",@"mississippi",
                         @"MO",@"missouri",
                         @"MT",@"montana",
                         @"NE",@"nebraska",
                         @"NV",@"nevada",
                         @"NH",@"new hampshire",
                         @"NJ",@"new jersey",
                         @"NM",@"new mexico",
                         @"NY",@"new york",
                         @"NC",@"north carolina",
                         @"ND",@"north dakota",
                         @"OH",@"ohio",
                         @"OK",@"oklahoma",
                         @"OR",@"oregon",
                         @"PA",@"pennsylvania",
                         @"RI",@"rhode island",
                         @"SC",@"south carolina",
                         @"SD",@"south dakota",
                         @"TN",@"tennessee",
                         @"TX",@"texas",
                         @"UT",@"utah",
                         @"VT",@"vermont",
                         @"VA",@"virginia",
                         @"WA",@"washington",
                         @"WV",@"west virginia",
                         @"WI",@"wisconsin",
                         @"WY",@"wyoming",
                         nil];
    
    if ([nameAbbreviations objectForKey:lowerCaseState])
    {
        return [nameAbbreviations objectForKey:lowerCaseState];

    }
    else
    {
        return state;
    }
}

@end
