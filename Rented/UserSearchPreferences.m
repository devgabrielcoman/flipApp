//
//  UserSearchPreferences.m
//  Rented
//
//  Created by Lucian Gherghel on 11/01/15.
//  Copyright (c) 2015 DevRented. All rights reserved.
//

#import "UserSearchPreferences.h"

@implementation UserSearchPreferences

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.minRenewalDays forKey:@"MinRenewalDays"];
    [encoder encodeInteger:self.maxRenewalDays forKey:@"MaxRenewalDays"];
    
    NSData *encodedVacancyTypes = [NSKeyedArchiver archivedDataWithRootObject:self.vacancyTypes];
    [encoder encodeObject:encodedVacancyTypes forKey:@"VacancyTypes"];
    
    [encoder encodeInteger:self.minRent forKey:@"MinRent"];
    [encoder encodeInteger:self.maxRent forKey:@"MaxRent"];
    
    [encoder encodeInteger:self.minSqFt forKey:@"MinSqFt"];
    [encoder encodeInteger:self.maxSqFt forKey:@"MaxSqFt"];
    
    [encoder encodeInteger:self.showRentalsInUserNetwork forKey:@"ShowRentalsInUserNetwork"];
    [encoder encodeInteger:self.hideFacebookProfile forKey:@"HideFacebookProfile"];

    
    NSData *encodedRoomTypes = [NSKeyedArchiver archivedDataWithRootObject:self.rooms];
    [encoder encodeObject:encodedRoomTypes forKey:@"RoomTypes"];
    
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.minRenewalDays = [decoder decodeIntegerForKey:@"MinRenewalDays"];
        self.maxRenewalDays = [decoder decodeIntegerForKey:@"MaxRenewalDays"];
        
        NSData *encodedVacancyTypes = [decoder decodeObjectForKey:@"VacancyTypes"];
        self.vacancyTypes = [NSKeyedUnarchiver unarchiveObjectWithData:encodedVacancyTypes];
        
        self.minRent = [decoder decodeIntegerForKey:@"MinRent"];
        self.maxRent = [decoder decodeIntegerForKey:@"MaxRent"];
        
        self.minSqFt = [decoder decodeIntegerForKey:@"MinSqFt"];
        self.maxSqFt = [decoder decodeIntegerForKey:@"MaxSqFt"];
        
        self.showRentalsInUserNetwork = [decoder decodeIntegerForKey:@"ShowRentalsInUserNetwork"];
        self.hideFacebookProfile = [decoder decodeIntegerForKey:@"HideFacebookProfile"];
        
        NSData *encodedRoomTypes = [decoder decodeObjectForKey:@"RoomTypes"];
        self.rooms = [NSKeyedUnarchiver unarchiveObjectWithData:encodedRoomTypes];
    }
    return self;
}

@end
