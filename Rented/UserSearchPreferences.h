//
//  UserSearchPreferences.h
//  Rented
//
//  Created by Lucian Gherghel on 11/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSearchPreferences : NSObject<NSCoding>

@property NSInteger minRenewalDays;
@property NSInteger maxRenewalDays;

@property NSArray *vacancyTypes;

@property NSInteger minRent;
@property NSInteger maxRent;

@property NSInteger minSqFt;
@property NSInteger maxSqFt;

@property NSArray *rooms;

@property NSInteger showRentalsInUserNetwork;
@property NSInteger hideFacebookProfile;


@end
