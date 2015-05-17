//
//  PrettyMessageHelper.m
//  Rented
//
//  Created by Cristian Olteanu on 5/16/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "PrettyMessageHelper.h"

@implementation PrettyMessageHelper

+(NSString *)shareApartmentMessageForApartment:(PFObject *)apartment
{

    NSString* ownerName = apartment[@"owner"][@"firstName"];
    NSString* apartmentType;
    if ([apartment[@"bedrooms"] integerValue]==0)
    {
        apartmentType = @"Studio";
    }
    if ([apartment[@"bedrooms"] integerValue]==1)
    {
        apartmentType = @"One Bedroom";
    }
    if ([apartment[@"bedrooms"] integerValue]==2)
    {
        apartmentType = @"Two Bedrooms";
    }
    if ([apartment[@"bedrooms"] integerValue]==3)
    {
        apartmentType = @"Three Bedrooms";
    }
    if ([apartment[@"bedrooms"] integerValue]==4)
    {
        apartmentType = @"Four Bedrooms";
    }
    if ([apartment[@"bedrooms"] integerValue]==5)
    {
        apartmentType = @"Five Bedrooms";
    }
    if (apartmentType == nil)
    {
        apartmentType = @"Apartment";
    }
    NSString* neighborhood = apartment[@"neighborhood"];
    NSString* message;

    message = [NSString stringWithFormat:@"Check out %@'s %@ in %@",ownerName,apartmentType,neighborhood];
 
    return message;
}

@end
