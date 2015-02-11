//
//  DependencyContainer.m
//  Rented
//
//  Created by Lucian Gherghel on 22/12/14.
//  Copyright (c) 2014 DevRented. All rights reserved.
//

#import "DependencyContainer.h"

@implementation DependencyContainer

static DependencyContainer *_instance;

+(void)load
{
    [self initiateDependencies];
}

+(DependencyContainer *)sharedInstance
{
    if(_instance==nil)
        _instance = [DependencyContainer new];
    return _instance;
}

+(void)initiateDependencies
{
    DEP.api = [RentedApi new];
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"rented_user_preferences"])
    {
        NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:@"rented_user_preferences"];
        DEP.userPreferences =  (UserSearchPreferences *) [NSKeyedUnarchiver unarchiveObjectWithData:serialized];
    }
    else
    {
        DEP.userPreferences = [UserSearchPreferences new];
        
        DEP.userPreferences.minRenewalDays = 0;
        DEP.userPreferences.maxRenewalDays = 365;
        DEP.userPreferences.vacancyTypes = @[];
        DEP.userPreferences.minRent = -1;
        DEP.userPreferences.maxRent = -1;
        DEP.userPreferences.minSqFt = -1;
        DEP.userPreferences.maxSqFt = -1;
        DEP.userPreferences.rooms = @[];
        DEP.userPreferences.address = @"";
        DEP.userPreferences.zipCode = @"";
    }
}

@synthesize authenticatedUser = _authenticatedUser;

- (void)setAuthenticatedUser:(PFUser *)user
{
    _authenticatedUser = user;
}

- (PFUser *)authenticatedUser
{
    if([DEP.api.userApi userIsAuthenticated])
        return [PFUser currentUser];
    
    return nil;
}

- (void)saveUserPreferences
{
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:DEP.userPreferences];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:@"rented_user_preferences"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
